# For knitting the rmd into an html document
generate_report <- function(){
  # knit rmd file into html document
  render("blast_history_report.Rmd", output_format = "html_document")
}


# For deleting the html and rmd documents
delete_report <- function(){
  # delete the rmd file and the html file it generates
  file.remove("blast_history_report.Rmd", "blast_history_report.html")
}

