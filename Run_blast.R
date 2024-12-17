# Pipeline to run blast search, retrieve hit sequences and then add metadata and summarize them

Run_Blast <- function(infile = file.choose(), dbtype = "nucl", database_outfile = NULL, 
                      taxids_file = NULL, btype = "blastn", qry, taxid=FALSE, ncores = 2, query_ids, 
                      NumHitseqs = 1, retrievSeqs_outfile, cut_seq = TRUE, 
                      MultFiles = FALSE, df1, id_col, summarize_cols, report = TRUE, numt=1,...)
{
  make_blast_db_message <- make_blast_db(infile, dbtype,database_outfile, taxids_file, report)
  database <- sub("Outfile name: (.*)", "\\1",make_blast_db_message[2])
  blst_search <- blstinr(btype,database,qry,taxid, report, ncores = ncores, numt=numt)
  retrieve_hit_seqs(query_ids, blst_search, database,NumHitseqs, retrievSeqs_outfile, cut_seq, MultFiles, report)
  summarize_bl(df1, blst_search, id_col, summarize_cols, report)
  
}