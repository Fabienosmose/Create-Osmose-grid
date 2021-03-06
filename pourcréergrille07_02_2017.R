#Script to build osm-med grid

rm(list = ls())

# Load libraries
library(igraph)
library(raster)
library(rgdal)
library(rgeos)

# Chargement SPDF de la M�diterran�e
fran <- readOGR("C:/Users/Fabien/Documents/Scripts R/Cartographie/pu_layerFrancois","planning_units")
med.proj <- spTransform(fran, CRS("+init=epsg:3035"))

# on enl�ve cellule dont aire est 40% sur terre
med.grid= med.proj[med.proj@data$area>(max(med.proj@data$area))*0.4,]

# Cr�ation d'un raster vide de r�solution 10km�
rastmed <- raster(ext=extent(med.grid),res=10000,crs =CRS("+init=epsg:3035"))
rastmed = setValues(rastmed,seq(1,length(rastmed),1))

# Cr�ation du raster Med avec -99 sur terre et 0 en mer
rast.med <- rasterize(med.grid,rastmed)
values(rast.med)[!is.na(values(rast.med))] <- 0
values(rast.med)[is.na(values(rast.med))] <- -99


# Pour enlever les cellules isol�es du reste de la M�diterran�e
values(rast.med)[(values(rast.med)==-99)] <- NA
values(rast.med)[(values(rast.med)==0)] <- 1
plot(rast.med)

# Clump raster
r <- clump(rast.med) # Possible d'ajouter directions=4 ou 8 (8 par d�faut)
freq(r)
plot(r)

# Pour modifier valeur des cellules isol�es
r[r==1] <- NA
plot(r)

# Pour remettre la terre en -99 et la mer en 0
values(r)[is.na(values(r))] <- -99
r[r==1] <- 0

# V�rification
plot(r)
sum(r@data@values==0)

# Le raster de la Med en 0 et -99 est transform� en Matrice puis sauvegard�
mat <- as.matrix(r)
map_med <- write.table(mat, "map_med.csv",row.names = F,col.names=F, sep = ",")

# Write raster in GTiff
writeRaster(x = r, filename = "rastmed.tif", format = "GTiff" )
