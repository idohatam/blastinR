#' Retrieve Hit Sequences from BLAST Search Results
#'
#' This function retrieves the hit sequences from a BLAST search, optionally trimming them to
#' just the aligned region. It allows for multiple hit retrievals per query and supports
#' exporting results to individual or combined FASTA files. This is useful when working with
#' large genomes where only the matched segment is desired.
#'
#' @param query_ids A character vector of query sequence IDs to retrieve hits for.
#' @param blast_results A data frame containing BLAST+ output (e.g., from `blstinr()`), including `sseqid`, `sstart`, and `send` columns.
#' @param blastdb A character string specifying the path/name of the BLAST database.
#' @param NumHitseqs Integer. Number of hit sequences to retrieve per query ID. Default is 1.
#' @param outfile A character string for the output file name (excluding file extension).
#' @param cut_seq Logical. If `TRUE` (default), retrieves only the aligned portion of each hit. If `FALSE`, retrieves the full sequence.
#' @param MultFiles Logical. If `TRUE`, saves each query’s hits to a separate FASTA file. Default is `FALSE`, saving all hits to a single file.
#' @param report Logical. If `TRUE` (default), results will be logged in the HTML report.
#' @param pipeline Logical. If `TRUE`, returns output file names instead of sequences, useful when chaining steps programmatically. Default is `FALSE`.
#'
#' @return A character vector of sequences (if `pipeline = FALSE`) or output file names (if `pipeline = TRUE`).
#' @export
#'
#' @examples
#' \dontrun{
#'   # Example usage after running a blast search with blstinr()
#'   blast_results <- read.csv("outputs/table/my_blast_results.csv")
#'   sequences <- retrieve_hit_seqs(
#'     query_ids = c("query1", "query2"),
#'     blast_results = blast_results,
#'     blastdb = "my_blast_db",
#'     NumHitseqs = 2,
#'     outfile = "retrieved_hits"
#'   )
#'   cat(sequences, sep = "\n")
#' }


retrieve_hit_seqs <- function(query_ids, blast_results, blastdb, NumHitseqs = 1, 
                              outfile, cut_seq = TRUE, MultFiles = FALSE, 
                              report = TRUE, pipeline = FALSE) {
  
  function_call_sig <- match.call()
  directory_check()
  directory_path <- "outputs/hits/"
  
  filenames_list <- list()
  
  # Initialize a string for +/- sequences for the header of each hit
  strOrientation <- "+"
  
  # Initialize a character vector to store the output
  output_lines <- character()
  
  # To store all output lines
  output_all <- character()
  
  # Loop through each query ID
  for (query_id in query_ids) {
    
    # Subset the blast results for the current query 
    query_results <- blast_results[blast_results$qseqid == query_id, ]
    
    # Loop through each hit sequence for the current query ID
    for (i in 1:min(NumHitseqs, nrow(query_results))) {
      
      # Extract the hit sequence ID
      hitSeq <- query_results$sseqid[i]
      
      # Use blastdbcmd to retrieve the hit sequence
      hit_sequence <- system2(
        command = "blastdbcmd",
        args = c("-db", blastdb, "-entry", hitSeq),
        stdout = TRUE,
        wait = TRUE
      )
      
      sequence_lines <- hit_sequence[-1]  # Skip the first line (header)
      full_sequence <- paste(sequence_lines, collapse = "")
      
      if (cut_seq == TRUE) {
        # Extract the start and end positions from query_results
        sstart <- query_results$sstart[i]
        send <- query_results$send[i]
        
        # +strand
        if(sstart < send){
          cut_seqs <- substr(full_sequence, sstart, send)
        }
        # -strand handling. Reverses the sequence within the range.
        else{
          
          strOrientation <- "-"
          cut_unreversed <- substr(full_sequence, send, sstart)
          cut_seqs <- paste(rev(strsplit(cut_unreversed, NULL)[[1]]), collapse = "")
        }
    
        
        # Append query ID and hit sequence ID to output_lines
        output_lines <- c(output_lines, paste(">", hitSeq, "__queryID:", 
                                              query_id, "_sstart:", sstart, 
                                              "_send:", send, "_Orientation:", 
                                              strOrientation, sep = ""))
        
        # Append hit sequence to output_lines
        output_lines <- c(output_lines, cut_seqs)
        
      } else {
        # Append query ID and hit sequence ID to output_lines
        output_lines <- c(output_lines, paste(">", hitSeq, "__queryID:", query_id, sep = ""))
        
        # Append hit sequence to output_lines
        output_lines <- c(output_lines, full_sequence)
      }
      
    }
    output_all <- c(output_all, output_lines)
    
    # If MultFiles is TRUE, write each query to a separate file
    if (MultFiles) {
      # Create a filename based on query ID and write output_lines to a file
      filename <- paste(directory_path, outfile, "_", query_id, ".fasta", sep = "")
      writeLines(output_lines, con = filename)
      
      filenames_list[[length(filenames_list) + 1]] <- filename
      
      # Clear output_lines for the next query ID
      output_lines <- character()
    }
    
  }
  
  # Write output_lines to a single text file if MultFiles is not TRUE
  if (!MultFiles) {
    filename <- paste(directory_path, outfile, ".fasta", sep = "") 
    writeLines(output_lines, con = filename)
    
    filenames_list[[length(filenames_list) + 1]] <- filename
  }
  

  if(report == TRUE){
  time <- time_func()
  directory_check()
  
  results_list <- list(data_table = NULL, plot_table = NULL, 
                       message = NULL, output_files = filenames_list)
  
  reporter_function(function_call_sig, results_list, time[[2]]);
  }
  
  if(pipeline == TRUE)
  {
    return(filenames_list)
  }
  
  # Return the output lines (optional, if needed for further processing)
  return(output_all)
}
