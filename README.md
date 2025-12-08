# Universal Data Analysis Image (Docker Compose)

### **Purpose**

This repository provides a general-purpose Docker image and Compose configuration for R-based data analysis. It is designed to support multiple projects, each with its own reproducible dependency management via `renv`. The image comes pre-loaded with common system libraries and R packages to ensure a smooth analysis workflow.

### **Quick Start: Setting Up the Environment**

Follow these steps to build and run the RStudio container. This is the first step required before running any analysis.

1.  **Configure Environment:** Edit the `.env` file to set your desired container name and host port.
    ```ini
    CONTAINER_NAME=universal-data-analysis
    HOST_PORT=8787
    IMAGE=lukasjirinovak/universal_data_analysis:latest
    ```

2.  **Add Projects:** Your R projects should be placed inside the `Projects/` directory. The repository already contains the loneliness meta-analysis project as an example.

3.  **Build and Run:**
    ```bash
    docker compose up --build -d
    ```

4.  **Access RStudio:** Open your browser and navigate to **`http://localhost:8787`** (or the port you specified).

---

### **Project Example: Reproducing the Loneliness Meta-Analysis**

Once the environment is running (following the Quick Start), you can reproduce the meta-analysis.

#### **File Locations**

*   **Project Directory:** All files for this specific project are located inside the container at:
    `Projects/loneliness-interventions-meta-analysis/`
*   **Input Data:** The raw data files are in:
    `Projects/loneliness-interventions-meta-analysis/Data/`
*   **Main Script:** The complete analysis is contained in the R Markdown file:
    `Projects/loneliness-interventions-meta-analysis/main.Rmd`

#### **How to Run the Analysis**

You have two options to run the analysis and generate the final report.

**Option 1: Using the RStudio Interface (Recommended)**

1.  In the RStudio "Files" pane (bottom-right), navigate to `Projects` -> `loneliness-interventions-meta-analysis`.
2.  Click on `main.Rmd` to open it in the editor.
3.  Click the **"Knit"** button at the top of the editor.

**Option 2: Using the RStudio Console**

1.  In the RStudio Console, run the following command:
    ```r
    rmarkdown::render("Projects/loneliness-interventions-meta-analysis/main.Rmd")
    ```

#### **Expected Output**

Running the script will produce a detailed HTML report named **`main.html`** in the `Projects/loneliness-interventions-meta-analysis/` directory. This self-contained file includes all the methods, results, tables, and figures for the meta-analysis.

### **Contact / Support**
Maintainer: lukas.novak <lukasjirinovak@gmail.com>