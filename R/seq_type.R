seq_type <- function(fasta_file) {
  # Read the file
  lines <- readLines(fasta_file)

  # Remove header lines (starting with ">")
  seq_lines <- lines[!grepl("^>", lines)]

  # Combine all sequences into one string
  sequence <- toupper(paste(seq_lines, collapse = ""))

  # Define letter set for unique protein sequences
  protein_unique <- c("Q","E","I","L","F","P","O","J","Z","X","*")


  # Split into individual characters
  seq_chars <- strsplit(sequence, "")[[1]]

  # Check for presence of unique indicators
  has_protein_letters <- any(seq_chars %in% protein_unique)

  # Decision logic
  if (has_protein_letters) {
    return("prot")
  } else {
    return("nucl")
  }
}

