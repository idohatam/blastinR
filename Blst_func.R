#a function to run the different blast serches from within R
# Parameters:
# btype: a string of the blast search, default is blastn
# dbase: a string of blast data base file name/path
# qry: a file of the query sequence
# Returns:
# a data frame of the blast search 
blst<- function(btype = "blastn", dbase,qry, taxid = FALSE, numt=1,...){
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
  
  # Return BLAST output
  return(bl_out)
}

