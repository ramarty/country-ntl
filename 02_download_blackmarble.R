# Download Black Marble Nighttime Lights

bearer <- read.csv(file.path(proj_dir,
                             "bm_token",
                             "bearer_bm.csv"))$token

for(country_i in countries){
  
  #### Create directories for rasters
  dir.create(file.path(country_data_dir, country_i,
                       "ntl_bm_rasters"))
  
  dir.create(file.path(country_data_dir, country_i,
                       "ntl_bm_rasters", "annual"))
  
  dir.create(file.path(country_data_dir, country_i,
                       "ntl_bm_rasters", "month"))
  
  dir.create(file.path(country_data_dir, country_i,
                       "ntl_bm_rasters", "day"))
  
  #### Load ROI
  roi_sf <- file.path(country_data_dir, country_i, "gadm") %>%
    list.files(full.names = T,
               pattern = "0_pk.rds") %>%
    readRDS()
  
  #### Download data
  
  ## Annually
  r_annual <- bm_raster(roi_sf = roi_sf,
                        product_id = "VNP46A4",
                        date = 2012:2023,
                        bearer = bearer,
                        output_location_type = "file",
                        file_dir = file.path(country_data_dir, country_i,
                                             "ntl_bm_rasters", "annual"))
  
  ## Monthly
  r_monthly <- bm_raster(roi_sf = roi_sf,
                         product_id = "VNP46A3",
                         date = seq.Date(from = ymd("2012-01-01"), 
                                         to = Sys.Date(), 
                                         by = "month"),
                         bearer = bearer,
                         output_location_type = "file",
                         file_dir = file.path(country_data_dir, country_i,
                                              "ntl_bm_rasters", "month"))
  
  ## Daily
  r_daily <- bm_raster(roi_sf = roi_sf,
                       product_id = "VNP46A2",
                       date = seq.Date(from = ymd("2023-01-01"), 
                                       to = ymd("2023-01-03"), 
                                       by = "day"),
                       bearer = bearer,
                       output_location_type = "file",
                       file_dir = file.path(country_data_dir, country_i,
                                            "ntl_bm_rasters", "day"))
  
}