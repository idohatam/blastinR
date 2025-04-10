# Pipeline to run blast search, retrieve hit sequences and then add metadata and summarize them


Run_Blast <- function(infile = file.choose(), dbtype = "nucl", database_outfile = NULL, 
                      taxids_file = NULL, btype = "blastn", qry, taxid=FALSE, ncores = 2, query_ids, 
                      NumHitseqs = 1, retrievSeqs_outfile, cut_seq = TRUE, 
                      MultFiles = FALSE, df1, id_col, summarize_cols, reporting = TRUE, numt=1,...)
{
  
  time <- time_func()
  function_call_sig <- match.call()
  
  make_blast_db_message <- make_blast_db(infile, dbtype,database_outfile, taxids_file, report = FALSE)
  
  database <- sub("Outfile name: (.*)", "\\1",make_blast_db_message[2])
  
  blst_search <- blstinr(btype,database,qry,taxid, report = FALSE, ncores = ncores, numt=numt)
 
  outfile_names_hit <- retrieve_hit_seqs(query_ids, blst_search, database,NumHitseqs, retrievSeqs_outfile, cut_seq, MultFiles, report = FALSE, pipeline = reporting)
  
  plot <- summarize_bl(df1, blst_search, id_col, summarize_cols, report = FALSE)
  
  
  if(reporting == TRUE){
    time <- time_func()
    Directory_check()
    
    blst_search_df <- as.data.frame(blst_search)
    print(blst_search_df)
    table_outputs_path <- paste0("outputs/table/",time[[1]],"_table.csv")
    
    write.table(blst_search_df, file = table_outputs_path, sep = ",", row.names = FALSE, quote = TRUE)
    html_outputs_path <- paste0("outputs/html/",time[[1]],"_plot.html")
    
    results_list <- list(data_table = table_outputs_path, plot_table = html_outputs_path, message = make_blast_db_message, output_files =  outfile_names_hit)
    reporter_function_pipeline(function_call_sig, results_list, time[[2]]);
    saveWidget(plot, file = html_outputs_path)
  }
  print(outfile_names_hit)
  return(plot)
  
}
