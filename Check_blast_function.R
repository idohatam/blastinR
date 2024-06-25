# a Function to check if BLAST is installed and the path is correct
# Parameters: 
# blpath: a string of command, default value is "makeblastdb"
# Returns:
# True if the path is found, throw an error if the path is not found


check_blast <- function(blpath = "makeblastdb")
{
  # Find the path to the BLAST executable
  bl <- Sys.which(paste(blpath))
  
  # Check if BLAST executable path was found
  if(nchar(bl) == 0){
    # If BLAST executable path not found, throw an error
    stop(paste("Can't find blast on the computer or the path can't be found, 
               make sure blast suite is properly installed"))
    }  
  # If BLAST executable path was found, print a message to confirm installation
  else
    {if(nchar(bl)>0){
    print("Blast is installed correctly and the path can be found.")
    return(TRUE)}
  }
}


