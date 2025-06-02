blastdb_type <- function(db_path) {
  output <- tryCatch(
    system2("blastdbcmd", args = c("-db", db_path, "-metadata"), stdout = TRUE, stderr = TRUE),
    error = function(e) return(NA)
  )

  # Search for the line that contains "dbtype"
  type_line <- grep('"dbtype"', output, value = TRUE)

  if (length(type_line) > 0) {
    if (grepl("protein", type_line, ignore.case = TRUE)) {
      return("prot")
    } else if (grepl("nucleotide", type_line, ignore.case = TRUE)) {
      return("nucl")
    }
  }
  #In case of database does not exist or path given was wrong.
  return("unknown")
}
