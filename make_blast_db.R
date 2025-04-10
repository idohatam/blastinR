# a function to make blast data base given the fasta file from within R
# Parameters:
# infile: input file name containing sequences, if not provided, 
#         a file dialog box is formed to allow the user to select an input file
# dbtype: a string of data base type, default is nucl
# outfile: output file name, if not provided the function removes .fa .fasta or .txt 
#          from the input file and uses it for the output name 
# taxids_file: a taxonomy information file, expected text file,
#        if added the function uses it to add these information when forming the data base
# Returns:
# a message confirming the success of data base formation 
# or an error message if data base formation was not successful 
make_blast_db <- function(infile = file.choose(), dbtype = "nucl", outfile = NULL, taxids_file = NULL, report = TRUE) {
  
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


