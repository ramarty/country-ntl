# Download GADM

for(country_i in countries){
  dir.create(file.path(country_data_dir, country_i))
  
  for(i in 0:5){
    gadm(country = country_i, 
         level=i, 
         path = file.path(country_data_dir, country_i))
  }
}