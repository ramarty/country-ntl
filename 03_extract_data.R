# Extract nighttime lights data

# TODO: gf / ngf -> replace with 0?
# TODO: Instead of different polygon for gf, just mask? YES DO THAT!

AGG_FUNS <- c("mean", "sum", "max")

# Prep gas flaring -------------------------------------------------------------
gf_df <- read_xlsx(file.path(gas_flare_dir, "rawdata", 
                             "GGFR-Flaring-Dashboard-Data-March292023.xlsx"))

gf_sf <- st_as_sf(gf_df, coords = c("Longitude", "Latitude"), crs = 4326)

# Loop through countries -------------------------------------------------------
for(country_i in countries){
  
  gadm_file_paths <- file.path(country_data_dir, country_i, "gadm") %>%
    list.files(full.names = T)
  
  # Loop through GADM files ----------------------------------------------------
  for(gadm_i in gadm_file_paths){
    
    ## Load data
    roi_sf <- readRDS(gadm_i) %>% st_as_sf()
    
    ## Separate into gas flaring / non-gas flaring
    inter_tf <- st_intersects(gf_sf, 
                              roi_sf %>% st_union(), 
                              sparse = F) %>%
      as.vector()
    gf_sf_i <- gf_sf[inter_tf,]
    
    gf_sf_buff_i <- st_buffer(gf_sf_i, dist = 5000) %>%
      st_union() %>%
      st_make_valid()
    
    roi_gf_sf   <- st_intersection(roi_sf, gf_sf_buff_i)
    roi_nogf_sf <- st_difference(roi_sf, gf_sf_buff_i)
    
    # Loop through NTL time types ----------------------------------------------
    for(time_type_i in c("annual", "month", "day")){
      cntry_ntl_dir <- file.path(country_data_dir, country_i, "ntl_bm_rasters")
      
      ntl_files <- list.files(file.path(cntry_ntl_dir, time_type_i),
                              full.names = T)
      
      # Loop though NTL files --------------------------------------------------
      for(ntl_file_i in ntl_files){
        
        date_i <- ntl_file_i %>%
          str_replace_all(".*_t", "") %>%
          str_replace_all(".tif", "")
        
        gadm_i_name <- gadm_i %>%
          str_replace_all("gadm41_", "") %>%
          str_replace_all("_pk.rds", "") %>%
          str_replace_all(".*/", "")
        
        ## Create paths
        dir.create(file.path(country_data_dir,
                             country_i, 
                             "ntl_bm_aggregated_individual_files",
                             gadm_i_name))
        
        dir.create(file.path(country_data_dir,
                             country_i, 
                             "ntl_bm_aggregated_individual_files",
                             gadm_i_name,
                             time_type_i))
        
        OUT_PATH <- file.path(country_data_dir,
                              country_i, 
                              "ntl_bm_aggregated_individual_files",
                              gadm_i_name,
                              time_type_i,
                              paste0("ntl_", date_i, ".Rds"))
        
        if(!file.exists(OUT_PATH)){
          
          r <- rast(ntl_file_i)
          
          # All locations --------------------------------------------------------
          ## Extract
          ntl_allloc_df <- exact_extract(r, roi_sf, fun = AGG_FUNS)
          names(ntl_allloc_df) <- paste0("ntl_bm_", names(ntl_allloc_df))
          
          ## Add data
          roi_df <- roi_sf %>%
            st_drop_geometry()
          
          roi_df <- bind_cols(roi_df, ntl_allloc_df)
          
          # Gas flaring locations ------------------------------------------------
          ## Extract
          ntl_gfloc_df <- exact_extract(r, roi_gf_sf, fun = AGG_FUNS)
          names(ntl_gfloc_df) <- paste0("ntl_bm_gf_", names(ntl_gfloc_df))
          
          ## Add ID
          id_var <- names(roi_gf_sf) %>%
            str_subset("GID_") %>%
            max()
          
          ntl_gfloc_df[id_var] <- roi_gf_sf[[id_var]]
          
          ## Merge with data
          roi_df <- roi_df %>%
            left_join(ntl_gfloc_df, by = id_var)
          
          # Non Gas flaring locations --------------------------------------------
          ## Extract
          ntl_nogfloc_df <- exact_extract(r, roi_nogf_sf, fun = AGG_FUNS)
          names(ntl_nogfloc_df) <- paste0("ntl_bm_nogf_", names(ntl_nogfloc_df))
          
          ## Add ID
          id_var <- names(roi_nogf_sf) %>%
            str_subset("GID_") %>%
            max()
          
          ntl_nogfloc_df[id_var] <- roi_nogf_sf[[id_var]]
          
          ## Merge with data
          roi_df <- roi_df %>%
            left_join(ntl_nogfloc_df, by = id_var)
          
          # Add date -------------------------------------------------------------
          if(time_type_i == "annual"){
            date_i <- date_i %>% as.numeric()
          } else if(time_type_i == "month"){
            date_i <- date_i %>%
              str_replace_all("_", "-") %>%
              paste0("-01") %>%
              ymd()
          } else if(time_type_i == "day"){
            date_i <- date_i %>%
              str_replace_all("_", "-") %>%
              ymd()
          }
          
          roi_df$date <- date_i
          
          # Export -------------------------------------------------------------
          saveRDS(roi_df, OUT_PATH)
          
        }
      }
    }
  }
}