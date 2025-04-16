#' Create a BLAST Database from a FASTA File
#'
#' This function wraps the BLAST+ `makeblastdb` command to create a BLAST database 
#' from a FASTA-formatted input file. Optionally, taxonomy information can be added 
#' using a tab-delimited taxonomy mapping file. A basic report can also be generated 
#' for reproducibility.
#'
#' @param infile A character string specifying the input FASTA file path. 
#'        If not provided, a file chooser dialog will open.
#' @param dbtype A string specifying the type of database to create. 
#'        Default is `"nucl"`; other option is `"prot"`.
#' @param outfile A string specifying the base name for the output database files. 
#'        If not supplied, the function will derive it from the input file name 
#'        by removing `.fa`, `.fasta`, or `.txt`.
#' @param taxids_file (Optional) A path to a taxonomy mapping file. 
#'        The file should be tab-delimited with two columns: sequence ID and taxonomy ID, 
#'        matching the format used by NCBI.
#' @param report Logical, default `TRUE`. If `TRUE`, a report entry is added via internal logging.
#'
#' @return A character vector with a success message or any error messages encountered during database creation.
#'
#' @details This function assumes that the BLAST+ suite, specifically the `makeblastdb` 
#'          executable, is correctly installed and available on the system PATH. 
#'          You can check installation status using [check_blast_install()].
#'
#' @seealso [check_blast_install()], [blstinr()]

#' 
#' @examples
#' \dontrun{
#' # Example: Create a nucleotide BLAST database from a FASTA file
#' make_blast_db(infile = "sequences.fasta", dbtype = "nucl", outfile = "my_blast_db")
#'
#' # Example with taxonomy mapping file
#' make_blast_db(infile = "sequences.fasta",
#'               dbtype = "nucl",
#'               outfile = "my_blast_db",
#'               taxids_file = "taxonomy_map.txt")
#' }
#' @export



make_blast_db <- function(infile = file.choose(), dbtype = "nucl", 
                          outfile = NULL, taxids_file = NULL, report = TRUE) {
  
  function_call_sig <- match.call()
  
  # Check if output file name is provided
  if (!file.exists(infile))
  {
    stop(paste("Can't find the file, check the file path or name and try again!"))
  }
  else{
    if (is.null(outfile)) {
      outfile <- gsub("\\.[^.]*$", "", infile)
    }
    
    # Form the command for makeblastdb to be passed to system2 
    cmd <- c("makeblastdb", "-in", infile, "-dbtype", dbtype, "-out", outfile, "-parse_seqids")
    
    #Add taxid_map option to the command if taxid_file is provided
    if (!is.null(taxids_file)) {
      cmd <- c(cmd, "-taxid_map", taxids_file)
    }
    
    # Execute system command and capture output
    output <- capture.output({
      system2(command = cmd, stdout = TRUE, wait = TRUE)
    })
    
    
    # Filter out the lines containing an error message
    error_lines <- grep("error:", output, value = TRUE)
    
    # Create a character vector to store messages
    msg <- character()
    
    # Store the output message to be returned 
    if (length(error_lines) > 0) {
      msg <- c(msg, paste(error_lines))
    } else {
      msg <- c(msg, "Blast database successfully created.", paste("Outfile name:", outfile))
    }
    
    if(report == TRUE){
      time <- time_func()
      results_list <- list(data_table = NULL, plot_table = NULL, message = msg, output_files = NULL)
      reporter_function(function_call_sig, results_list, time[[2]]);
    }
    # Return the message
    return(msg)
  }
}
