# Script to change continent map on species distribution for osmose 
# Author : Fabien Moullec
# Date : 07/02/2017

rm(list = ls())

# Load libraries
library(rgdal)
library(raster)
library(rgeos)
library(fields)
library(matlab)

# Chargement du raster de la MED
rast.med <- readGDAL("C:/Users/Fabien/Documents/Scripts R/création des inputs osmose/grille osmose/rastmed.tif")
rast.med <- raster(rast.med)

# chargement du dossier "map" de la config osmose
files <- list.files("C:/Users/Fabien/Documents/OSMOSE-MED/Osm_version_4/maps")
setwd("C:/Users/Fabien/Documents/OSMOSE-MED/Osm_version_4/maps")

# Récupération des coordonnées long-lat du raster de la Med
grid <- coordinates(rast.med)
grid[,2]=rev(grid[,2])

# Loop over files to add the new mask on species distribution maps
for (i in seq_along(files)) { 
  matr <- read.csv(files[i], sep = ",", header = F)
  mat <- as.matrix(matr)
  mat <- fliplr(t(mat))
  vec <- as.vector(mat)
  tab <- cbind(grid,vec)
  r <- rasterFromXYZ(tab, res = 10000, crs = CRS("+init=epsg:3035"))
  # Add the new mask
  # To add only the cell with -99, the cells equal to '0' are transformed in NAs
  values(rast.med)[(values(rast.med)==0)] <- NA
  r.mask <- mask(r, rast.med, maskvalue=-99)
  # Change NA values by -99
  values(r.mask)[is.na(values(r.mask))] <- -99
  # Transform in matrix the raster
  mat.rast <- as.matrix(r.mask)
  # Write the csv file in a folder named "carte_essai" in "Documents"
  map_med <- write.table(mat.rast, file = (paste0("C:/Users/Fabien/Documents/carte_essai/",files[i])),row.names = F,col.names=F, sep = ",")
  }
# 
