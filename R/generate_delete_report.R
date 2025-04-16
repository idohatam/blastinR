#' Generate the BLAST HTML Report
#'
#' Uses `rmarkdown::render()` to knit the `blast_history_report.Rmd` file into an HTML report.
#' This function must be called by the user after running BLAST-related functions if they want
#' to generate a formatted report of their analysis.
#'
#' @details
#' The function assumes that a file named `blast_history_report.Rmd` exists in the current working
#' directory. This file is expected to have been incrementally updated by internal logging functions
#' such as `reporter_function()`.
#'
#' @return No return value. An HTML file `blast_history_report.html` is created as a side effect.
#' 
#' #' @importFrom rmarkdown render
#'
#' @export
#'
#' @examples
#' 
#' \dontrun{
#' # Generate the BLAST HTML report
#' generate_report()
#' }
generate_report <- function(){
  render("blast_history_report.Rmd", output_format = "html_document")
}


#' Delete the BLAST Report Files
#'
#' Deletes both the `blast_history_report.Rmd` and `blast_history_report.html` files from the
#' working directory.
#'
#' @details
#' This function is useful if you want to start a new BLAST analysis and clear out the
#' previously generated report. It is non-reversible and should be used with caution.
#'
#' @return No return value. Deletes files as a side effect.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Delete the current BLAST report and start fresh
#' delete_report()
#' }
#' 
delete_report <- function(){
  file.remove("blast_history_report.Rmd", "blast_history_report.html")
}

