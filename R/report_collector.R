# Creates an rmd file which acts as a scientific report, detailing the user's interaction with the program's functions. 
# NOTE* This function is NOT called by the pipeline.
# Parameters:
# function_call:  an inputted function call with its parameters
# data_list:  a list holding the data outputted from the function which calls this reporter function. Will usually hold file paths
# entry_time: The execution time of the function which called the reporter function.
# Returns:
# RMD file: "blast_history_report.rmd"

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








