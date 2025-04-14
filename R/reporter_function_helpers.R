# creates labels for the R markdown chunks
label_generator <- function(){
  return(paste0(UUIDgenerate()))
}


# For conversion of the message list into a string, which will be neatly presented in the final report
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


# Fixes issues with the function_call, making it clear and presentable in the final report as a code chunk
fix_functionCall <- function(function_call) {
  function_call <- deparse(function_call)  # Convert to character string representation
  function_call <- paste(function_call, collapse = " ")  # correcting collapses
  function_call <- gsub("\\s*,\\s*", ",", function_call)  # Remove extra spaces around commas
  function_call <- gsub("\\s+", " ", function_call)  # Normalize spaces
  function_call <- trimws(function_call)  # Remove leading/trailing spaces
  return(function_call)
}