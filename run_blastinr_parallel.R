if (!require(foreach)) {
  install.packages("foreach", dependencies = TRUE)
  library(foreach)
} else {
  library(foreach)
}

if (!require(doParallel)) {
  install.packages("doParallel", dependencies = TRUE)
  library(doParallel)
} else {
  library(doParallel)
}

# library(foreach)
# library(doParallel)

# a function to run blastr in parallel given the number of cores or threads
# Parameters: 
# btype: blast type
# dbase: blast database file path/name
# qry: a fasta file with sequences to be queried
# taxid: Boolean value, default is FALSE and assumes no ids were added to the database during make blast database, 
#        if TRUE is passed it would add a column in the dataframe to show the added ids 
# report` default parameter is TRUE. Creates a report or adds to an existing report.
# ncores: number of cores/threads to be used
# numt: (to be filled in)
# Returns: 
# A dataframe with the query results
blstinr <- function(btype = "blastn", dbase, qry, taxid = FALSE,report = TRUE, ncores = 2, numt = 1, ...) {
  
  function_call_sig <- match.call()
  if (ncores == 1){
    results <- blst(btype = btype, dbase = dbase, qry = qry, taxid = taxid, numt = numt, ...)
  }
  else{
    # Function to split fasta file into chunks
    split_fasta <- function(file, n) {
      # Read the fasta file
      fasta <- readLines(file)
      # Find the indices of the headers
      headers <- grep("^>", fasta)
      # Split the headers into chunks
      chunks <- split(headers, cut(seq_along(headers), n, labels = FALSE))
     
      # Create temporary files for each chunk
      temp_files <- lapply(1:length(chunks), function(i) {
        temp_file <- tempfile(fileext = ".fasta")
        
        if (i == ncores) {
          idx <- length(fasta)
        } else {
          idx <- chunks[[i + 1]][1] - 1
        }
        
        writeLines(fasta[chunks[[i]][1]:idx], temp_file)
        return(temp_file)
      })
      return(temp_files)
    }
   
    # Split the fasta file
    chunks <- split_fasta(qry, ncores)
    
    # Register the parallel backend
    cl <- makeCluster(ncores)
    registerDoParallel(cl)
    
    # Export necessary objects to the cluster
    clusterExport(cl, c("blst", "time_func", "Directory_check", "reporter_function", "fix_functionCall", "label_generator"))
    
    # Run the blstinr function in parallel using foreach
    results <- foreach(chunk = chunks, .combine = rbind, .packages = c("dplyr", "tidyr", "uuid", "data.table", "ggplot2", "DT", "knitr", "rmarkdown")) %dopar% {
      blst(btype = btype, dbase = dbase, qry = chunk, taxid = taxid, numt = numt, ...)
    }
   
    # Stop the cluster
    stopCluster(cl)
  }
  if(report == TRUE){
    time <- time_func() 
    Directory_check()
    table_outputs_path <- paste0("outputs/table/",time[[1]],"_table.csv")  
    write.table(results, file = table_outputs_path, sep = ",", row.names = FALSE, quote = TRUE)
    results_list <- list(data_table = table_outputs_path, plot_table = NULL, message = NULL, output_files = NULL)
    reporter_function(function_call_sig, results_list, time[[2]])
  }
  
  return(results)
}