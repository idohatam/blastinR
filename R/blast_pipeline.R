# a function of Pipeline to run blast search, retrieve hit sequences and then add metadata and summarize them
# Parameters:
# infile: input file name containing sequences, if not provided,
#         a file dialog box is formed to allow the user to select an input file
# dbtype: a string of data base type, default is nucl
# database_outfile: output file name, if not provided the function removes .fa .fasta or .txt
#          from the input file and uses it for the output name for blast database creation.
# taxids_file: a taxonomy information file, expected text file,
#        if added the function uses it to add these information when forming the data base
# btype: a string of the blast search, default is blastn
# qry: a fasta file with sequences to be queried
# taxid: Boolean value, default is FALSE and assumes no ids were added to the database during make blast database,
#        if TRUE is passed it would add a column in the dataframe to show the added ids
# ncores: number of cores/threads to be used
# query_ids: a vector of query IDs
# NumHitseqs: Integer value, the number of hit sequences to be retrieved for each
#             query id passed, default is 1.
# retrievSeqs_outfile: output file name for the hit sequences
# cut_seq: Boolean value, default is TRUE and cuts the hit sequences from start to end of the match.
#          if FALSE is passed, it'll retrieve the full hit sequence.
# MultFiles: Boolean value, default is FALSE and outputs all the hit sequences for all query ids in one output file.
#            If TRUE is passed, the function will create one file for each query id's hit sequences.
# df1: The dataframe that has the added metadata.
# id_col: A string containing the column name of the ID to merge dataframes with.
# summarize_cols: A vector that contains the names of the columns to summarize.
# reporting: default parameter is TRUE. Creates a report or adds to an existing report.
# Returns:
# a data frame of the blast search


blast_pipeline <- function(infile = file.choose(), dbtype = "nucl", 
                           database_outfile = NULL,
                      taxids_file = NULL, btype = "blastn", qry, 
                      taxid=FALSE, ncores = 2, query_ids,
                      NumHitseqs = 1, retrievSeqs_outfile, cut_seq = TRUE,
                      MultFiles = FALSE, df1, id_col, summarize_cols, 
                      reporting = TRUE, numt=1,...)
{

  time <- time_func()
  function_call_sig <- match.call()

  make_blast_db_message <- make_blast_db(infile, dbtype,database_outfile, 
                                         taxids_file, report = FALSE)

  database <- sub("Outfile name: (.*)", "\\1",make_blast_db_message[2])

  blst_search <- blstinr(btype,database,qry,taxid, report = FALSE, 
                         ncores = ncores, numt=numt)

  outfile_names_hit <- retrieve_hit_seqs(query_ids, blst_search, database,NumHitseqs, 
                                         retrievSeqs_outfile, cut_seq, MultFiles, 
                                         report = FALSE, pipeline = reporting)

  plot <- summarize_bl(df1, blst_search, id_col, summarize_cols, report = FALSE)


  if(reporting == TRUE){
    time <- time_func()
    directory_check()

    blst_search_df <- as.data.frame(blst_search)
    print(blst_search_df)
    table_outputs_path <- paste0("outputs/table/",time[[1]],"_table.csv")

    write.table(blst_search_df, file = table_outputs_path, sep = ",", 
                row.names = FALSE, quote = TRUE)
    
    html_outputs_path <- paste0("outputs/html/",time[[1]],"_plot.html")

    results_list <- list(data_table = table_outputs_path, 
                         plot_table = html_outputs_path, 
                         message = make_blast_db_message, 
                         output_files =  outfile_names_hit)
    
    reporter_function_pipeline(function_call_sig, results_list, time[[2]]);
    saveWidget(plot, file = html_outputs_path)
  }
  print(outfile_names_hit)
  return(plot)

}
