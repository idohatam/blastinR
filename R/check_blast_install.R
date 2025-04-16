#' Check if BLAST+ is Installed and Accessible
#'
#' This function checks whether the BLAST+ suite is installed and whether the specified command
#' (e.g., \code{makeblastdb}) is available in the system's executable search path.
#' It can be used interactively or internally to validate the environment.
#'
#' @param blpath A character string specifying the BLAST+ command to check.
#' Defaults to \code{"makeblastdb"}.
#'
#' @return A character message confirming that BLAST+ is correctly installed and the path is set.
#' Throws an error if the executable is not found.
#'
#' @details This function uses \code{Sys.which()} to search for the specified BLAST+ tool
#' in the system's \code{PATH}. If the tool is not found, the function stops with an error
#' message prompting the user to check their BLAST+ installation.
#'
#' Currently, only the system \code{PATH} is searched, but support for specifying custom paths
#' may be added in future versions (e.g., for use with containers or virtual environments).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' check_blast_install()
#' check_blast_install("blastn")
#' check_blast_install("blastp")
#' }
#' 
check_blast_install <- function(blpath = "makeblastdb")
{
  # Find the path to the BLAST executable
  bl <- Sys.which(paste(blpath))
  
  # Check if BLAST executable path was found
  if(nchar(bl) == 0){
    # If BLAST executable path not found, throw an error
    stop(paste("Can't find blast on the computer or the path can't be found, 
               make sure blast+ is properly installed or that the path to it is specified"))
    }  
  # If BLAST executable path was found, returns a message to confirm installation
  else
    {if(nchar(bl)>0){
    msg <- paste("blast+ is installed correctly and the path to it is specified.")
    return(msg)}
  }
}