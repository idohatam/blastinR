# Pipeline to run blast search, retrieve hit sequences and then add metadata and summarize them

Run_Blast <- function(btype = "blastn", dbase,qry, taxid=FALSE,
                      query_ids, NumHitseqs = 1, outfile, cut_seq = TRUE, MultFiles = FALSE,
                      df1, id_col, summarize_cols, numt=1,...){
  database <- dbase
  blst_search <- blstinr(btype,dbase,qry,taxid)
  retrieve_hit_seqs(query_ids, blst_search, database,NumHitseqs, outfile, cut_seq, MultFiles)
  summarize_bl(df1, blst_search, id_col, summarize_cols)
  
}

