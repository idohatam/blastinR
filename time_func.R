time_func <- function(){
  
  time_list <- list()
  sys_time <- Sys.time() #save the time
  timeStamp_global <- format(sys_time, "%Y%m%d%H%M%S") # time stamp for naming output files
  entry_time <- timestamp(stamp = sys_time, prefix = "--- ", suffix = " ---", quiet = FALSE) # time stamp for the report
  time_list[[length(time_list) + 1]] <- timeStamp_global
  time_list[[length(time_list)+1]] <- entry_time
  return(time_list)
}
