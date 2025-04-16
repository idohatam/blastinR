#' Check and Create Output Directories
#'
#' This internal helper function ensures that the necessary output directories
#' (`outputs/html`, `outputs/table`, `outputs/hits`) exist within the working
#' directory. If any of them are missing, it creates them.
#'
#' @keywords internal
#' @noRd

directory_check <- function(){
  # Define the base directory
  base_dir <- "outputs"
  
  # List of sub-directories to create
  subdirs <- c("html", "table", "hits")
  
  # Create base directory if it does not exist
  if (!file.exists(base_dir)) {
    dir.create(base_dir)
  }
  
  # Loop through and create each sub-directory if it does not exist
  for (subdir in subdirs) {
    subdir_path <- file.path(base_dir, subdir)
    if (!file.exists(subdir_path)) {
      dir.create(subdir_path)
    }
  }
}