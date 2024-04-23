# Country Nighttime Lights

countries <- c("DZA")

# Filepaths --------------------------------------------------------------------
## Root
proj_dir <- "/Users/rmarty/Library/CloudStorage/OneDrive-WBG/Country Nighttime Lights"

## From root
data_dir <- file.path(proj_dir, "data")
country_data_dir <- file.path(data_dir, "country_data")
global_data_dir  <- file.path(data_dir, "global_data")

gas_flare_dir <- file.path(global_data_dir, "gas_flaring")

# Packages ---------------------------------------------------------------------
library(tidyverse)
library(dplyr)
library(blackmarbler)
library(geodata)
library(sf)
library(terra)
library(exactextractr)
library(readxl)
library(haven)
