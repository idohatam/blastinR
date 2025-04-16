#' Generate a unique label for R Markdown code chunks
#'
#' This internal helper function uses `UUIDgenerate()` from the **uuid** package to 
#' create a unique label for use in dynamically generated R Markdown reports.
#'
#' @return A unique character string.
#' @importFrom uuid UUIDgenerate
#' @noRd

label_generator <- function(){
  return(paste0(UUIDgenerate()))
}


#' Convert a list of messages into a single HTML-friendly string
#'
#' This internal helper function takes a list of messages and converts it into
#' a single formatted string suitable for R Markdown output, using `<br>` tags for line breaks.
#'
#' @param messageList A list of character strings to be concatenated.
#'
#' @return A single character string combining all messages with HTML line breaks.
#' @noRd

list_to_string <- function(messageList){
  str <- ""
  for(i in messageList){
    str <- paste0(str,i)
    str <- paste0(str,"\n")
    str <- paste0(str,"<br>")
    str <- paste0(str,"\n")
    
  }
  return(str)
}

#' Clean and format recorded function calls for R Markdown reporting
#'
#' This internal helper function takes a raw `match.call()` output and processes it
#' into a clean, readable string suitable for inclusion in an R Markdown code chunk.
#'
#' @param function_call A function call object captured with `match.call()`.
#'
#' @return A cleaned-up character string of the function call.
#' @noRd

fix_functionCall <- function(function_call) {
  function_call <- deparse(function_call)  # Convert to character string representation
  function_call <- paste(function_call, collapse = " ")  # correcting collapses
  function_call <- gsub("\\s*,\\s*", ",", function_call)  # Remove extra spaces around commas
  function_call <- gsub("\\s+", " ", function_call)  # Normalize spaces
  function_call <- trimws(function_call)  # Remove leading/trailing spaces
  return(function_call)
}