#' Run BLAST Searches in Parallel
#'
#' This function performs BLAST searches in parallel using the `foreach` and `doParallel` packages.
#' It automatically splits the input query FASTA file into chunks, distributes them across the specified
#' number of cores, and then combines the results. If only one core is specified, it runs a regular search
#' using an internal wrapper.
#'
#' @param btype A string indicating the BLAST search type (e.g., `"blastn"`). Default is `"blastn"`.
#' @param dbase The path to the BLAST database file to be used in the search.
#' @param qry A FASTA file containing the query sequences.
#' @param taxid Logical. If `TRUE`, assumes taxonomy IDs were added during database creation and appends them to results.
#'              Default is `FALSE`.
#' @param report Logical. If `TRUE` (default), a report is generated and saved in the `outputs/table/` directory.
#' @param ncores Integer. Number of cores to use for parallel processing. Default is `2`.
#' @param numt Integer. Passed to internal calls, typically corresponds to the number of threads for `blastn`. Default is `1`.
#' @param ... Additional arguments passed to the internal BLAST wrapper function.
#'
#' @return A data frame with the combined BLAST search results from all cores.
#'
#' @examples
#' \dontrun{
#' # Run a parallel BLAST search with 4 cores
#' parallel_blast(
#'   btype = "blastn",
#'   dbase = "my_database",
#'   qry = "queries.fasta",
#'   taxid = TRUE,
#'   report = TRUE,
#'   ncores = 4,
#'   numt = 1
#' )
#' }
#'
#' @importFrom foreach foreach %dopar%
#' @importFrom doParallel registerDoParallel stopImplicitCluster
#' @importFrom parallel makeCluster stopCluster clusterExport
#' @importFrom utils write.table readLines
#' @importFrom stats cut
#' @importFrom dplyr bind_rows
#' @export

parallel_blast <- function(btype = "blastn", dbase, qry, taxid = FALSE,report = TRUE, ncores = 2, numt = 1, ...) {
  
  function_call_sig <- match.call()
  if (ncores == 1){
    results <- prll_blst_call(btype = btype, dbase = dbase, qry = qry, taxid = taxid, numt = numt, ...)
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
    clusterExport(cl, c("prll_blst_call", "time_func", "directory_check", 
                        "reporter_function", "fix_functionCall", 
                        "label_generator"))
    
    # Run the blstinr function in parallel using foreach
    results <- foreach(chunk = chunks, .combine = rbind, 
                       .packages = c("dplyr", "tidyr", "uuid", 
                                     "data.table", "ggplot2", "DT", 
                                     "knitr", "rmarkdown")) %dopar% {
      prll_blst_call(btype = btype, dbase = dbase, qry = chunk, taxid = taxid, numt = numt, ...)
    }
   
    # Stop the cluster
    stopCluster(cl)
  }
  if(report == TRUE){
    time <- time_func() 
    directory_check()
    table_outputs_path <- paste0("outputs/table/",time[[1]],"_table.csv")  
    write.table(results, file = table_outputs_path, sep = ",", 
                row.names = FALSE, quote = TRUE)
    
    results_list <- list(data_table = table_outputs_path, plot_table = NULL, 
                         message = NULL, output_files = NULL)
    reporter_function(function_call_sig, results_list, time[[2]])
  }
  
  return(results)
}