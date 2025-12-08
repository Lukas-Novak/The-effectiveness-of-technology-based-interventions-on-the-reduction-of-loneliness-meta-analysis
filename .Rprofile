# Default .Rprofile for the universal-data-analysis-image project
# This file is intentionally minimal. Projects can include their own `.Rprofile`
# under `Projects/<project>`.

# Example: Do not set global options in this placeholder; add per-project `.Rprofile`
# in `Projects/your-project/.Rprofile` when needed.

# Source autosnapshot hook (defaults to enabled; set RENV_AUTOSNAPSHOT=0 to disable)
hook <- file.path("/home/rstudio/scripts/renv_snapshot_on_exit.R")
if (file.exists(hook)) {
	try(source(hook, local = TRUE), silent = TRUE)
}

invisible(NULL)
