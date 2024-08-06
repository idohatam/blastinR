#a function that generates a Sankey plot summarizing categorical 
#information based on taxonomic identifiers from blast search data frames in R


summerize_bl <- function(df1, df2, id_col, summarize_cols) {
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
  nodes <- data.frame(name = unique(c("All IDs", unlist(percentage_df[summarize_cols]))))
  
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

 time <- time_func()
 Directory_check()
 html_outputs_path <- paste0("outputs/html/",time[[1]],"_plot.html")
 results_list <- list(data_table = NULL, plot_table = html_outputs_path, message = NULL, output_files = NULL)
 reporter_function(function_call_sig, results_list, time[[2]]);
 saveWidget(plot, file = html_outputs_path)
 
 return(plot)
}

