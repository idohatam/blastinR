#' Generate an R Markdown report documenting function usage
#'
#' This internal function builds an R Markdown (`.Rmd`) file that logs function calls,
#' outputs, and messages for various BLAST+ functions. It is used for creating a
#' reproducible report of user interactions. This function is not used by the pipeline wrapper.
#'
#' @param function_call The raw `match.call()` of the calling function.
#' @param data_list A named list containing output data, such as file paths, messages,
#' tables (`data_table`), plots (`plot_table`), and file outputs (`output_files`).
#' @param entry_time A timestamp or string indicating when the function was executed.
#'
#' @return None. A file called `"blast_history_report.rmd"` is created or appended to in the working directory.
#'
#' @details
#' The report includes:
#' - The function name and call.
#' - An optional DT-rendered HTML table if `data_table` is provided.
#' - Embedded plots (via `include_url`) if `plot_table` is provided.
#' - A message block or output file list if available.
#'
#' This function uses internal helpers like `label_generator()`, `fix_functionCall()`, and `list_to_string()`.
#'
#' @noRd


reporter_function <- function(function_call, data_list, entry_time){
  print(function_call)
  function_call <- fix_functionCall(function_call)
  rmd_file <- "blast_history_report.rmd" # name of rmd file
  if(!file.exists(rmd_file)){
    file.create(rmd_file)
    title <- c(
      "---",
      "title: \"BLAST+ History\"",
      "output: html_document",
      "---",
      "\n"
    )
    writeLines(title, rmd_file)
  }
  rmd_content <- readLines(rmd_file)
  
  rmd_content_time <- c(paste0("### ", entry_time))
  rmd_content_new <- c()
  
  
  
  # For printing the make_blast_db message
  data_list$message <- gsub("\\\\", "/", data_list$message)
  if(!is.null(data_list$message)){
    make_db_content <- c(
      paste0("#### **Function Name: make_blast_db**"),
      paste0("```{r ", label_generator(),",eval = FALSE}\n",
             function_call,"\n",
             "```"),
      paste0(data_list$message),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')
      )
    rmd_content_new <- c(make_db_content)
  }
  
  
  # The time stamp of the entry
  if(!is.null(data_list$data_table)){
    table_content <- c(
      paste0("#### **Function Name: blstinr**"),
      paste0("```{r ", label_generator(),",eval = FALSE}\n",
             function_call,"\n",
             "```"),
      paste0("```{r ", label_generator(),", echo=FALSE,warning = FALSE}\n",
             "library(DT)\n",
             "data <- read.csv('",data_list$data_table,"')\n",
             "datatable(data)\n",
             "```"),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')
      )
    
    rmd_content_new <- c(table_content);
  }
  
  # if plot_table is not null, then it contains a plot
  if(!is.null(data_list$plot_table)){
    
      plot_content<- c(
        paste0("#### **Function Name: Summarize_bl**"),
        paste0("```{r ", label_generator(),",eval = FALSE}\n",
               function_call,"\n",
               "```"),
        paste0("```{r ",label_generator(),", echo=FALSE , out.width = '80%', warning = FALSE}","\n",
               paste0("knitr::include_url('",data_list$plot_table,"')"),"\n",
               "```"),
        paste0('\n'),
        paste0('<br>'),
        paste0('\n')

      )
      rmd_content_new <- c(plot_content)
      

  }
  
  
  
  #outputs list of files
  if(!is.null(data_list$output_files)){
    file_list <- list_to_string(data_list$output_files)
    output_content <- c(
      paste0("#### **Function Name: retrieve_hit_seqs**"),
      paste0("```{r ", label_generator(),",eval = FALSE}\n",
             function_call,"\n",
             "```"),
      paste0(file_list),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')
      )
    
    rmd_content_new <- c(output_content)
  }
  
  # check if the rmd file exists
  if (file.exists(rmd_file)) {
    # reads in what is already in the file
    rmd_content <- readLines(rmd_file)
    
    
    # combine the new content with the content that was already in the rmd file
    if(all(rmd_content_time %in% rmd_content)){
      update_content <- c(rmd_content, rmd_content_new)
    }
    else{
      update_content <- c(rmd_content, rmd_content_time, rmd_content_new)
      
    }
    
    # write in the new concatenation
    writeLines(update_content, rmd_file)
    
  } 
  
}








