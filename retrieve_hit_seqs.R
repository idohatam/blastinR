# a function to retrieve the hit sequence from blast search results from within R
# Parameters: 
# query_ids: a vector of query IDs
# blast_results: a data frame of blast search results
# blastdb: blast database file path/name
# outfile: output file name
# Returns: 
# Hit sequences as a vector of characters
retrieve_hit_seqs <- function(query_ids, blast_results, blastdb, outfile, cut_seq = TRUE) {
  
  # Initialize a character vector to store the output
  output_lines <- character()
  
  # Loop through each query ID
  for (query_id in query_ids) {
    
    # Subset the blast results for the current query 
    query_results <- blast_results[blast_results$qseqid == query_id, ]
    
    # Extract the hit sequence ID assuming it is the first one in the result
    hitSeq <- query_results$sseqid[1]
    
    # Use blastdbcmd to retrieve the hit sequence
    hit_sequence <- system2(
      command = "blastdbcmd",
      args = c("-db", blastdb, "-entry", hitSeq),
      stdout = TRUE,
      wait = TRUE
    )
    
    sequence_lines <- hit_sequence[-1]  # Skip the first line (header)
    full_sequence <- paste(sequence_lines, collapse = "")
    
    if(cut_seq == TRUE){
    
    # Extract the start and end positions from query_results
    sstart <- query_results$sstart[1]
    send <- query_results$send[1]
    cut_seqs <- substr(full_sequence, sstart, send)
    
    # Append query ID and hit sequence ID to output_lines
    output_lines <- c(output_lines, paste(">", hitSeq, "__queryID:", query_id, "_sstart:", sstart, "_send:", send, sep = ""))
    
    # Append hit sequence to output_lines
    output_lines <- c(output_lines, cut_seqs)
    }
    
    else{
    # Append query ID and hit sequence ID to output_lines
    output_lines <- c(output_lines, paste(">", hitSeq, "__queryID:", query_id, sep = ""))
    
    # Append hit sequence to output_lines
    output_lines <- c(output_lines, full_sequence)
    
  }
  }
  # Write output_lines to a text file
  writeLines(output_lines, con = outfile)
  
  # Return the output lines
  return(output_lines)
}

