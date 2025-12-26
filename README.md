# Loneliness Interventions Meta-Analysis  
**Reproducible R analysis using Docker, RStudio, and renv**

## Purpose

This repository contains all data, code, and infrastructure required to reproduce a meta-analysis of loneliness interventions.

The analysis is implemented in **R**, with package versions locked via **renv**, and can be executed either:

- locally (with R installed), or  
- in a fully reproducible **Docker + RStudio** environment (recommended).

The repository follows a **single-project layout**. No external project scaffolding is required.

---

## Repository Structure

```

loneliness-interventions-meta-analysis/
├── data_and_code/                # Analysis code and data
│   ├── Data/                     # Input data
│   ├── Exploration_of_wierd_values/
│   ├── Pooled_correlations_calculation/
│   ├── main.Rmd                  # Main analysis script
│   ├── main.html                 # Rendered report (output)
│   └── README.md                 # Project-specific notes
├── Dockerfile                    # R + system dependencies
├── docker-compose.yml            # RStudio container configuration
├── renv.lock                     # Locked R package versions
└── README.md                     # (this file)

````

---

## Running the Analysis (Recommended: Docker)

### 1. Build and start the container

From the repository root:

```bash
docker compose up --build -d
````

### 2. Open RStudio

Navigate to:

```
http://localhost:8787
```

Authentication is disabled by default (see `docker-compose.yml`).

### 3. Project location inside the container

The repository root is mounted into the container at:

```
/home/rstudio/project
```

All analysis files are therefore available at:

```
/home/rstudio/project/data_and_code/
```

---

## Running the Meta-Analysis

### Option A: Using RStudio (recommended)

1. Open `data_and_code/main.Rmd`
2. Click **Knit**

### Option B: Using the R console

```r
rmarkdown::render("data_and_code/main.Rmd")
```

The rendered report (`main.html`) will appear in the same directory.

---

## Running Without Docker (Local Execution)

If you prefer to run the analysis locally:

1. Open an R session in the repository root
2. Restore dependencies:

```r
renv::restore()
```

3. Render the analysis:

```r
rmarkdown::render("data_and_code/main.Rmd")
```

---

## Reproducibility

* **R package versions** are fixed via `renv.lock`
* **System dependencies** are fixed via Docker
* The generated HTML report (`main.html`) is fully self-contained and suitable for sharing or archiving

---

## Contact

Maintainer: **Lukáš Novák**
📧 [lukas.jirinovak@gmail.com](mailto:lukas.jirinovak@gmail.com)

