#' Generate an R Markdown report for pipeline execution
#'
#' This internal function builds an R Markdown (`.Rmd`) report to document the
#' execution of the `blast_pipeline` function. It logs each step within the
#' pipeline—including `make_blast_db`, `blstinr`, `retrieve_hit_seqs`, and
#' `summarize_bl`—with corresponding inputs, outputs, messages, and plots.
#'
#' @param function_call The raw `match.call()` of the `blast_pipeline()` pipeline function.
#' @param data_list A named list containing output elements:
#' - `message`: output from `make_blast_db()`
#' - `data_table`: a path to the CSV generated by `blstinr()`
#' - `output_files`: vector of result filenames from `retrieve_hit_seqs()`
#' - `plot_table`: a URL pointing to a plot created by `summarize_bl()`
#' @param entry_time A timestamp string representing when `blast_pipeline()` was called.
#'
#' @return None. A file named `"blast_history_report.rmd"` is created or appended to in the working directory.
#'
#' @details
#' This function uses internal helpers: `label_generator()`, `fix_functionCall()`, and `list_to_string()`.
#'
#' The resulting R Markdown file can be knitted to HTML for an organized, readable report of the entire BLAST+ pipeline.
#'
#' @noRd

reporter_function_pipeline <- function(function_call, data_list, entry_time){
  
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
  
  
  
  title <- c(
    paste0("#### **Function Name: blast_pipeline**"),
    paste0("#### Executing blast_pipeline pipeline function: \n"),
    paste0("```{r ", label_generator(),",eval = FALSE}\n",
           function_call,"\n",
           "```"),
    paste0('\n'),
    paste0('<br>'),
    paste0('\n')
    )
  rmd_content_new <- c(title)
  
  
  data_list$message <- gsub("\\\\", "/", data_list$message)
  if(!is.null(data_list$message)){
    make_db_content <- c(
      paste0("#### **Function Name: make_blast_db**"),
      paste0("#### Creating a local BLAST database with the input FASTA file: \n"),
      paste0(data_list$message),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')
      
    )
    rmd_content_new <- c(rmd_content_new,make_db_content)
  }
  
  
  if(!is.null(data_list$data_table)){
    table_content_pipeline <- c(
      paste0("#### **Function Name: blstinr**"),
      paste0("#### Running BLAST tool with inputted query against the local database: \n"),
      paste0("```{r ", label_generator(),", echo=FALSE,warning = FALSE}\n",
             "library(DT)\n",
             "data <- read.csv('",data_list$data_table,"')\n",
             "datatable(data)\n",
             "```"),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')      
    )
    rmd_content_new <- c(rmd_content_new, table_content_pipeline);
  }
  
  
  #outputs list of files
  if(!is.null(data_list$output_files)){
    file_list <- list_to_string(data_list$output_files)
    retrieved_hit_seqs_pipeline <- c(
      paste0("#### **Function Name: retrieve_hit_seqs**"),
      paste0("#### Retrieving hits based on indicated query id(s): \n"),
      paste0(file_list),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')
      )
    
    rmd_content_new <- c(rmd_content_new, retrieved_hit_seqs_pipeline);
  }
  
  
  if(!is.null(data_list$plot_table)){
    
    plot_content<- c(
      paste0("#### **Function Name: summarize_bl**"),
      paste0("#### Summarizing the distribution of data based on added metadata: \n"),
      paste0("```{r ",label_generator(),", echo=FALSE , out.width = '80%', warning = FALSE}","\n",
             paste0("knitr::include_url('",data_list$plot_table,"')"),"\n",
             "```"),
      paste0('\n'),
      paste0('<br>'),
      paste0('\n')
    )
    rmd_content_new <- c(rmd_content_new,plot_content)
    
    
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
