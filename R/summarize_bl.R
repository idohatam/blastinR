#' Summarize and Visualize BLAST+ Results with Metadata using a Sankey Plot
#'
#' This function merges functional or categorical metadata with BLAST+ results based on a shared taxonomic ID,
#' summarizes the data across selected columns, and visualizes the summary as a Sankey plot. The function is
#' useful for visualizing how BLAST hit sequences distribute across taxonomic or functional groups.
#'
#' Assumes the BLAST database used for the search contains a "taxonomy" table and that BLAST+ results (e.g. from `blstinr()`)
#' include a `staxids` column. The metadata table should have one row per `tax_id` with any associated annotations.
#'
#' @param df1 A data frame of metadata with one row per taxonomic identifier (`tax_id`), including functional annotations.
#' @param df2 A data frame of BLAST+ results, including a `staxids` column (e.g., the output from `blstinr()`).
#' @param id_col A string giving the column name in `df1` that matches `df2$staxids`.
#' @param summarize_cols A character vector of column names (from the metadata table) to group by and visualize in the Sankey plot.
#' @param report Logical. If `TRUE` (default), saves the Sankey plot to an HTML report file and logs it.
#'
#' @return An interactive Sankey plot (`htmlwidget`).
#' @export
#'
#' @importFrom dplyr left_join group_by summarise mutate select across bind_rows n sym
#' @importFrom tidyr everything
#' @importFrom magrittr %>%
#' @importFrom networkD3 sankeyNetwork
#' @importFrom htmlwidgets saveWidget
#'
#' @examples
#' \dontrun{
#' # Assuming df2 is from blstinr() and df1 is a metadata table with "tax_id" and "Function"
#' sankey_plot <- summarize_bl(
#'   df1 = metadata_df,
#'   df2 = blast_results_df,
#'   id_col = "tax_id",
#'   summarize_cols = c("Function")
#' )
#' print(sankey_plot)
#' }


summarize_bl <- function(df1, df2, id_col, summarize_cols, report = TRUE) {
  function_call_sig <- match.call()
  # Merge the data frames on ID
  merged_df <- df2 %>%
    left_join(df1, by = c("staxids" = id_col))
  
  
  # Calculate the total count
  total_count <- nrow(merged_df)
  
  # Summarize the columns
  percentage_df <- merged_df %>%
    group_by(across(all_of(summarize_cols))) %>%
    summarise(count = n(), .groups = 'drop') %>%
    mutate(percentage = (count / total_count) * 100)
  
  
  # Prepare nodes for Sankey plot
  nodes <- data.frame(name = unique(c("All IDs", 
                                      unlist(percentage_df[summarize_cols]))))
  
  # Define links
  links <- data.frame()
  for (i in seq_along(summarize_cols)) {
    if (i == 1) {
      links_temp <- percentage_df %>%
        group_by(across(all_of(summarize_cols[i]))) %>%
        summarise(count = sum(count), .groups = 'drop') %>%
        mutate(source = match("All IDs", nodes$name) - 1,
               target = match(!!sym(summarize_cols[i]), nodes$name) - 1,
               pct = (count / total_count) * 100
               ) %>%
        select(source, target, pct)
    } else {
      links_temp <- percentage_df %>%
        mutate(source = match(!!sym(summarize_cols[i - 1]), nodes$name) - 1,
               target = match(!!sym(summarize_cols[i]), nodes$name) - 1,
               pct = (count / total_count) * 100
               )%>%
        select(source, target, pct)
    }
    links <- bind_rows(links, links_temp)
  }
  
  # Convert to plain data frame if needed
  links <- as.data.frame(links)
  
  # Create the sankey plot
 plot <- sankeyNetwork(Links = links, Nodes = nodes,
                Source = "source", Target = "target",
                Value = "pct", NodeID = "name",
                sinksRight = TRUE)

 if(report == TRUE){
 time <- time_func()
 directory_check()
 html_outputs_path <- paste0("outputs/html/",time[[1]],"_plot.html")
 results_list <- list(data_table = NULL, plot_table = html_outputs_path, 
                      message = NULL, output_files = NULL)
 reporter_function(function_call_sig, results_list, time[[2]]);
 saveWidget(plot, file = html_outputs_path)
 }
 return(plot)
}