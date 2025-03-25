# Pipeline to run blast search, retrieve hit sequences and then add metadata and summarize them

Run_Blast <- function(infile = file.choose(), dbtype = "nucl", database_outfile = NULL, 
                      taxids_file = NULL, btype = "blastn", qry, taxid=FALSE, ncores = 2, query_ids, 
                      NumHitseqs = 1, retrievSeqs_outfile, cut_seq = TRUE, 
                      MultFiles = FALSE, df1, id_col, summarize_cols, report = TRUE, numt=1,...)
{
  function_call_sig <- match.call()
  make_blast_db_message <- make_blast_db(infile, dbtype,database_outfile, taxids_file, FALSE)
  database <- sub("Outfile name: (.*)", "\\1",make_blast_db_message[2])
  blst_search <- blstinr(btype,database,qry,taxid, FALSE, ncores = ncores, numt=numt)
  retrieve_hit_seqs(query_ids, blst_search, database,NumHitseqs, retrievSeqs_outfile, cut_seq, MultFiles, FALSE)
  plot <- summarize_bl(df1, blst_search, id_col, summarize_cols, FALSE)
  
  if(report == TRUE){
    time <- time_func()
    Directory_check()
    html_outputs_path <- paste0("outputs/html/",time[[1]],"_plot.html")
    results_list <- list(data_table = NULL, plot_table = html_outputs_path, message = NULL, output_files = NULL)
    reporter_function(function_call_sig, results_list, time[[2]]);
    saveWidget(plot, file = html_outputs_path)
  }
  return(plot)
  
}