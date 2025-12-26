FROM rocker/tidyverse:4.5.1@sha256:b340dd5c2867463cb51380a490d2e4af5c7fe24b5def6c8b445fe08b46088043

LABEL maintainer="lukas.novak <lukasjirinovak@gmail.com>"

# Environment Setup
ENV DEBIAN_FRONTEND=noninteractive

# Avoid LD_LIBRARY_PATH warnings in some setups
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PATH=/usr/local/bin:$PATH

# Tell reticulate to reuse a single Miniconda install (if you use reticulate later)
ENV RETICULATE_MINICONDA_PATH=/opt/miniconda

# Where user-level R packages could go (we mostly rely on renv)
ENV R_LIBS_USER=/home/rstudio/Packages

# renv cache location (compose mounts a named volume here)
ENV RENV_PATHS_CACHE=/home/rstudio/.cache/R/renv

# Allow rstudio user to use sudo without a password
RUN echo "rstudio ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install system packages needed to build common R packages
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
    bzip2 \
    sudo \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libx11-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (optional, but kept from your original image)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda && \
    rm miniconda.sh

ENV PATH="/opt/miniconda/bin:$PATH"
RUN pip install --upgrade pip==25.0

# Working Directory & Permissions
WORKDIR /home/rstudio/

# Fix ownership and permissions
RUN sudo chown -R rstudio:rstudio /home/rstudio/ && \
    mkdir -p /home/rstudio/Packages /home/rstudio/.cache/R/renv && \
    chown -R rstudio:rstudio /home/rstudio/Packages /home/rstudio/.cache && \
    chmod -R 777 /tmp/

# Install renv (pinned)
RUN sudo R -e "Sys.setenv(RENV_VERSION='1.0.3'); install.packages(paste0('https://cran.r-project.org/src/contrib/Archive/renv/renv_', Sys.getenv('RENV_VERSION'), '.tar.gz'), repos=NULL, type='source')"

# Build-time dependency restore (cache-friendly)
# Copy only renv.lock first so Docker can cache package restore layers
WORKDIR /home/rstudio/project
COPY --chown=rstudio:rstudio renv.lock /home/rstudio/project/renv.lock

USER rstudio

# Restore packages according to renv.lock during build.
# Note: When you bind-mount the repo at runtime, you can re-run renv::restore()
# if you changed renv.lock after building the image.
RUN R -e "options(renv.consent=TRUE); renv::restore(lockfile='renv.lock', prompt=FALSE)"

# Mark repo as safe for git inside container (avoids warnings if .git is mounted)
RUN git config --global --add safe.directory /home/rstudio/project || true

USER root

EXPOSE 8787
CMD ["/init"]
