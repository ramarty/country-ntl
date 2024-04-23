# Append data

for(country_i in countries){
  
  gadm_file_paths <- file.path(country_data_dir, country_i, "gadm") %>%
    list.files(full.names = T)
  
  for(gadm_i in gadm_file_paths){
    
    gadm_i_name <- gadm_i %>%
      str_replace_all("gadm41_", "") %>%
      str_replace_all("_pk.rds", "") %>%
      str_replace_all(".*/", "")
    
    for(time_type_i in c("annual", "month", "day")){
      
      ntl_df <- file.path(country_data_dir,
                          country_i, 
                          "ntl_bm_aggregated_individual_files",
                          gadm_i_name,
                          time_type_i) %>%
        list.files(full.names = T,
                   pattern = ".Rds") %>%
        map_df(readRDS)
      
      write_dta(ntl_df,
                file.path(country_data_dir,
                          country_i,
                          "ntl_bm_aggregated",
                          paste0(gadm_i_name, "_", time_type_i, ".dta")))
      
    }
  }
}