#' Pipeline to Run BLAST Search, Retrieve Hits, Annotate, and Summarize
#'
#' This function wraps the entire BLAST workflow in one call: it creates a BLAST database,
#' performs a BLAST search, retrieves hit sequences, overlays metadata, and generates
#' a Sankey plot summarizing the results.
#'
#' @param infile Character. Path to the input file used to create the BLAST database. If not provided,
#'   a file dialog box will open.
#' @param dbtype Character. BLAST database type. Default is `"nucl"`.
#' @param database_outfile Character. Optional. File name for the BLAST database. If not provided, the function
#'   will derive a name by removing `.fa`, `.fasta`, or `.txt` from the input file name.
#' @param taxids_file Character. Optional path to a taxonomy ID file to include when building the database.
#' @param btype Character. BLAST search type (e.g., `"blastn"`, `"blastp"`). Default is `"blastn"`.
#' @param qry Character. Path to the FASTA file of query sequences.
#' @param taxid Logical. Whether taxonomy IDs were added during database creation. Default is `FALSE`.
#' @param ncores Integer. Number of threads to use. Default is `2`.
#' @param query_ids Character vector. Query sequence IDs for which to retrieve hit sequences.
#' @param NumHitseqs Integer. Number of hit sequences to retrieve per query. Default is `1`.
#' @param retrievSeqs_outfile Character. Output file name or prefix for retrieved hit sequences.
#' @param cut_seq Logical. If `TRUE`, extract only aligned regions of hits. If `FALSE`, extract full sequences. Default is `TRUE`.
#' @param MultFiles Logical. If `TRUE`, save hit sequences in separate files for each query ID. Default is `FALSE`.
#' @param df1 Data frame. Metadata table containing additional information (e.g., functional annotation) keyed by taxonomy ID.
#' @param id_col Character. Column name in `df1` that corresponds to the `tax_id` used in the BLAST database.
#' @param summarize_cols Character vector. Names of the metadata columns to include in the Sankey plot.
#' @param reporting Logical. If `TRUE`, saves a report including the BLAST results and Sankey plot. Default is `TRUE`.
#' @param numt Integer. An optional argument passed to the BLAST wrapper (e.g., for number of top hits to keep). Default is `1`.
#' @param ... Additional arguments passed to internal functions.
#'
#' @return A named list with two elements:
#' \describe{
#'   \item{blast_results}{A data frame of the parsed BLAST search results.}
#'   \item{summary_plot}{An interactive Sankey plot summarizing metadata for BLAST hits.}
#' }
#'
#' @export
#' 
#' #' @examples
#' \dontrun{
#' blast_pipeline(
#'   infile = "data/sequences.fasta",
#'   qry = "data/queries.fasta",
#'   query_ids = c("query1", "query2"),
#'   retrievSeqs_outfile = "outputs/hits",
#'   df1 = read.csv("data/metadata.csv"),
#'   id_col = "tax_id",
#'   summarize_cols = c("Function", "Pathway"),
#'   reporting = TRUE
#' )
#' }

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
  return(list(blast_results = blst_search, sankey_plot = plot)

}
