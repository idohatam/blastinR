#A function listing avaliable sequences in NCBI datasets (for now just genomes)

library("RCurl")
library("XML")

list_seqs <- function(db = "refseq", dl_list = FALSE, org){
  
  ncbi <- "https://ftp.ncbi.nlm.nih.gov/genomes/"
  
  if(db != "refseq" & db != "genbank"){
    stop("db only accepts refseq or genbank as values, execution stopped")
  } 
  
  
}

