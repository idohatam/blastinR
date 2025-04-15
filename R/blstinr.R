#' Run BLAST+ Searches from Within R
#'
#' This function allows users to run various BLAST+ search types (e.g., \code{blastn}, \code{blastp}) directly from R.
#' It wraps a system call to the BLAST+ command-line tools and processes the output into a tidy tibble,
#' optionally including taxonomic identifiers and saving the results to disk.
#'
#' @param btype Character string specifying the BLAST tool to use. Defaults to \code{"blastn"}.
#' @param dbase Character string giving the path to the BLAST database.
#' @param qry Character string giving the path to the query FASTA file.
#' @param taxid Logical. If \code{TRUE}, includes taxonomic IDs in the output. Defaults to \code{FALSE}.
#' @param numt Integer. Number of threads to use for BLAST. Defaults to \code{1}.
#' @param ... Additional arguments passed to \code{system2()}, if needed.
#'
#' @return A tibble containing BLAST results, including columns for sequence identifiers, alignment metrics,
#' and optionally taxonomic information. A CSV of the results is saved to \code{outputs/table/}.
#'
#' @details This function requires the BLAST+ suite to be installed and accessible via the system \code{PATH}.
#' The output is parsed into a tibble and augmented with a column \code{Range} representing alignment length.
#' Internal helper functions handle directory setup, timestamping, and report logging.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' blstinr(btype = "blastn", dbase = "nt", qry = "query.fasta")
#' blstinr(btype = "blastp", dbase = "swissprot", qry = "protein.fasta", taxid = TRUE, numt = 4)
#' }
#'
#' @importFrom magrittr %>%
#' @importFrom tibble as_tibble
#' @importFrom tidyr separate
#' @importFrom dplyr mutate

blstinr <- function(btype = "blastn", dbase,qry, taxid = FALSE,numt=1,...){
  function_call_sig <- match.call()
  # Define the column names for the BLAST output
  colnames_a <- c("qseqid","sseqid","pident","length","mismatch","gapopen","qstart",
                "qend","sstart","send","evalue","bitscore")
  colnames_b <-c(colnames_a,"staxids")
  
  # Check the path to the BLAST executable
  bt <- Sys.which(paste(btype))
  
  # if BLAST executable path was not found, throw an error
  if(nchar(bt) == 0){
    stop(paste("Can't find",btype,
               "on the computer, make sure balast suite is properly installed",
               sep = " "))} 
  # If BLAST executable path found, execute the BLAST command
  else{if(nchar(bt)>0){
                  if(taxid==FALSE){
                 # Run BLAST search using system2 command
                 bl_out <-system2(command = paste(bt), 
                                  args = c("-db", paste(dbase),
                                           "-query", paste(qry),
                                           "-outfmt", "6",
                                           "-num_threads", paste(numt)), 
                                  wait = TRUE, stdout = TRUE) %>% 
                   as_tibble() %>%  # form a tibble data frame from the tabular output
                   separate(col = 1, into = colnames_a,sep = "\t", # Separate a single column into multiple columns 
                            convert = TRUE) %>% 
                   mutate(Range = send - sstart)} # add a new column, Range, which represents the length of the alignment  
  else
  {
    bl_out <-system2(command = paste(bt), 
                     args = c("-db", paste(dbase),
                              "-query", paste(qry),
                              "-outfmt", shQuote("6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids"),
                              "-num_threads", paste(numt)), 
                     wait = TRUE, stdout = TRUE) %>% 
      as_tibble() %>%  # form a tibble data frame from the tabular output
      separate(col = 1, into = colnames_b,sep = "\t", # Separate a single column into multiple columns 
               convert = TRUE) %>% 
      mutate(Range = send - sstart)}} # add a new column, Range, which represents the length of the alignment    
  }
  time <- time_func() 
  directory_check()
  table_outputs_path <- paste0("outputs/table/",time[[1]],"_table.csv")  
  write.table(bl_out, file = table_outputs_path, sep = ",", row.names = FALSE, quote = TRUE)
  results_list <- list(data_table = table_outputs_path, plot_table = NULL, 
                       message = NULL, output_files = NULL)
  reporter_function(function_call_sig, results_list, time[[2]])
  
  # Return BLAST output
  return(bl_out)
}
