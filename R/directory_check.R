#' Check and Create Output Directories
#'
#' This internal helper function ensures that the necessary output directories
#' (`outputs/html`, `outputs/table`, `outputs/hits`, `outputs/db`) exist within the working
#' directory. If any of them are missing, it creates them.
#' html stores the html report along with any figure that's generated
#' table stores any table that is generated
#' hits stores any exported fasta files with hits from blast searches
#' db stores databse files outputed from blastdb
#'
#' @keywords internal
#' @noRd

directory_check <- function(){
  # Define the base directory
  base_dir <- "outputs"

  # List of sub-directories to create
  subdirs <- c("html", "table", "hits","db")

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
