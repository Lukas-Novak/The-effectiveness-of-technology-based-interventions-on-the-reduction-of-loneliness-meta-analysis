FROM rocker/tidyverse:4.5.1@sha256:b340dd5c2867463cb51380a490d2e4af5c7fe24b5def6c8b445fe08b46088043 AS base
LABEL maintainer="lukas.novak <lukasjirinovak@gmail.com>"

# --- Environment Setup ---
ENV DEBIAN_FRONTEND=noninteractive

# Explicitly set LD_LIBRARY_PATH to avoid warnings
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PATH=/usr/local/bin:$PATH

# Tell reticulate to reuse the same Miniconda installation
ENV RETICULATE_MINICONDA_PATH=/opt/miniconda

# Set R_LIBS_USER so that R installs packages in a directory accessible to the rstudio user
ENV R_LIBS_USER=/home/rstudio/Packages

# --- Allow rstudio user to use sudo without a password ---
RUN echo "rstudio ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install system packages needed to build R packages (including `bootnet` dependencies)
RUN apt-get update && apt-get install -y \
    apt-utils \
    git \
    wget \
    build-essential \
    gfortran \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    libdb-dev \
    libgdbm-dev \
    tk-dev \
    liblzma-dev \
    libncurses5-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    cmake \
    pkg-config \
    libnlopt-dev \
    libgsl-dev \
    libglpk-dev \
    libglpk40 \
    libgmp-dev \
    libudunits2-dev \
    libatlas-base-dev \
    libopenblas-dev \
    libblas-dev \
    liblapack-dev \
    libfreetype6-dev \
    libpng-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libmpfr-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libcairo2-dev \
    libxt-dev \
    libmagick++-dev \
    libfribidi-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    libgmp3-dev \
    libncursesw5-dev \
    bzip2 \
    sudo \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libx11-dev \
    && rm -rf /var/lib/apt/lists/*

# --- Install Miniconda ---
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda && \
    rm miniconda.sh

# Ensure conda binaries are in PATH
ENV PATH="/opt/miniconda/bin:$PATH"
RUN pip install --upgrade pip==25.0

# --- Working Directory & Permissions ---
WORKDIR /home/rstudio/
# Fix ownership and permissions for the working directory and temporary directory
RUN sudo chown -R rstudio:rstudio /home/rstudio/ && \
    chmod -R 777 /home/ && \
    sudo chmod -R 777 /tmp/

# Make sure system R library exists and has correct permissions
RUN mkdir -p /usr/local/lib/R/site-library && \
    chown -R root:root /usr/local/lib/R/site-library && \
    chmod -R 755 /usr/local/lib/R/site-library

# NOTE: We only install core R packages into the system site-library when
# there are NO per-project `renv.lock` files. When per-project renv lockfiles
# are present we rely on `renv::restore()` in the `renv-builder` stage so
# project dependencies are captured in the image cache.

# Provide envs for renv and site libraries
# renv: per-project library root (keeps project libraries inside project/renv)
ENV RENV_PATHS_LIBRARY=renv/library
# R_LIBS_SITE should include the system site-library so packages installed
# into /usr/local/lib/R/site-library are available by default.
ENV R_LIBS_SITE=/usr/local/lib/R/site-library

# Install renv itself
RUN sudo R -e "Sys.setenv(RENV_VERSION='1.0.3'); install.packages(paste0('https://cran.r-project.org/src/contrib/Archive/renv/renv_', Sys.getenv('RENV_VERSION'), '.tar.gz'), repos=NULL, type='source')"

# ---- renv builder stage: install project dependencies into a cached layer ----
FROM base AS renv-builder
WORKDIR /home/rstudio

# Copy Projects and profile files. The builder will look for per-project
# renv.lock files in `Projects/*/renv.lock` and run `renv::restore()` for each
# project that has a lockfile. This avoids build failure when no renv.lock is
# present and runs fast when `Projects` doesn't change (cacheable layer).
COPY --chown=rstudio:rstudio Projects /home/rstudio/Projects
COPY --chown=rstudio:rstudio .Rprofile /home/rstudio/.Rprofile

# If there are no per-project renv.lock files, install a small set of common
# packages into the central system library so they're available to users even
# when project volumes are bind-mounted. If renv.lock is present we skip this
# and rely on `renv::restore()` below to populate per-project libraries.
RUN if ls /home/rstudio/Projects/*/renv.lock >/dev/null 2>&1; then \
        echo 'Found per-project renv.lock files; skipping global package installs.'; \
    else \
        echo 'No renv.lock files found; installing core R packages into /usr/local/lib/R/site-library'; \
        printf '%s\n' \
            "install.packages(c('nlme', 'lme4'), lib='/usr/local/lib/R/site-library', Ncpus = min(2L, parallel::detectCores()))" \
            "if (!requireNamespace('remotes', quietly = TRUE)) {" \
            "  install.packages('remotes', repos='https://cloud.r-project.org')" \
            "}" \
            "remotes::install_github('Lukas-Novak/psychtoolbox', lib='/usr/local/lib/R/site-library')" \
            "install.packages('bootnet', dependencies = TRUE, lib='/usr/local/lib/R/site-library')" \
            > /tmp/install_core.R; \
        Rscript /tmp/install_core.R; \
    fi

USER rstudio
RUN bash -lc "set -e; \
    echo 'Scanning Projects for renv.lock files and restoring per-project renv if present'; \
    for PROJECT_DIR in /home/rstudio/Projects/*; do \
        if [ -d \"${PROJECT_DIR}\" ]; then \
            if [ -f \"${PROJECT_DIR}/renv.lock\" ]; then \
                echo 'Found renv.lock in' ${PROJECT_DIR}; \
                Rscript -e \"setwd('${PROJECT_DIR}'); renv::restore()\"; \
            else \
                echo 'No renv.lock in' ${PROJECT_DIR}, 'skipping'; \
            fi; \
        fi; \
    done"

USER root

# Copy renv cache out (the whole renv directory) so the final image can reuse it
# Ensure the `renv` folder exists so that final `COPY --from=renv-builder` never fails
RUN mkdir -p /home/rstudio/renv && chown -R rstudio:rstudio /home/rstudio/renv || true

# ---- Final image stage ----
FROM base AS final
WORKDIR /home/rstudio

# Copy the cached renv library from the renv-builder stage if present
COPY --from=renv-builder /home/rstudio/renv /home/rstudio/renv

# Copy all project files (this step is last to keep earlier layers cached)
COPY . /home/rstudio

# Fix ownership and invite the rstudio user to use the repo files
RUN chown -R rstudio:rstudio /home/rstudio && chown -R rstudio:rstudio /home/rstudio/Packages || true

# Ensure renv library permissions are correct
RUN chown -R rstudio:rstudio /home/rstudio/renv || true

USER rstudio
RUN git config --global --add safe.directory /home/rstudio || true

USER root
EXPOSE 8787
CMD ["/init"]