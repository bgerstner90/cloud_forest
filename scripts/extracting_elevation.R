#Extracting elevation values from each GBIF dataset

library(raster)

#read in elevation raster 
elev <- raster("/Users/bethgerstner/Desktop/srtm_1km.tif")

#read in latitude longitude data
col_birds_2000_2010<-read.csv("/Users/bethgerstner/Desktop/birds_colombia/co_birds_2000_2010/co_birds_2000_2010/co_birds_2000_2010_occurrence.csv")

#Extract only the columns that we want (coordinates)
##I changed the column names for the coordinates to say long and lat
col_birds_2000_2010_coords <-col_birds_2000_2010[,c("long","lat")]

#Convert the coordinates into spatialpoints so that can be used to extract raster data 
#has to be the same projection as the SRTM elevation raster 
point <- SpatialPoints(col_birds_2000_2010_coords, proj4string = CRS("+proj=longlat +datum=WGS84") )

#extract elevation values for each coordinate
col_birds_2000_2010_coords_elev <- extract(elev, point,df=TRUE, method='simple')

#combine coordinates and elevation into a single dataframe
col_birds_2000_2010_coords_elev_final <- cbind(col_birds_2000_2010_coords_elev, col_birds_2000_2010_coords)

#check the column names
head(col_birds_2000_2010_coords_elev_final)
               
#Rename the elevation column 
colnames(col_birds_2000_2010_coords_elev_final)[colnames(col_birds_2000_2010_coords_elev_final)=="srtm_1km"] <- "SRTM_elevation"

#remove ID column
col_birds_2000_2010_coords_elev_final$ID <- NULL

#reorder columns
col_birds_2000_2010_coords_elev_final <-col_birds_2000_2010_coords_elev_final[c("long", "lat", "SRTM_elevation")]

# Put both GBIF datasets and elevation dataset together 
col_birds_2000_2010_coords_elev_final_full <- cbind(col_birds_2000_2010, col_birds_2000_2010_coords_elev_final)

#subset the full dataset by elevation 
col_birds_2000_2010_elev_subset <- subset(col_birds_2000_2010_coords_elev_final_full, SRTM_elevation >= 1000 & SRTM_elevation <=3200)

#sort the data
col_birds_2000_2010_elev_subset <- col_birds_2000_2010_elev_subset[order(col_birds_2000_2010_elev_subset$SRTM_elevation),] 

#write a new csv file
setwd("/Users/bethgerstner/Desktop/birds_colombia/co_birds_2000_2010/co_birds_2000_2010")

##make sure you are changing the file name here so we don't overwrite everything
write.csv(col_birds_2000_2010_elev_subset, file="CO_birds_2000_2010_elev_subset.csv")

## read in final database
final_data <- read.csv("/Users/bethgerstner/Desktop/bird_mammal_gbif_elton_IUCN.csv")

final_data_co_ec <-  final_data[which(final_data$countryCode=='CO' | final_data$countryCode=='EC'),] ##if there is a CO or EC in these columns then that means it has GBIF Data

setwd("/Users/bethgerstner/Desktop/birds_colombia/final_database")
write.csv(final_data_co_ec, file="Final_CO_EC_database.csv")

##For checking species names: if it has an IUCN status and no Elton trait values, the species name is probably different and you’ll have to look that up.
##An easy way to do that as a quick check is to load in your elton traits database and then search for the different species name:
#birds - would be the name of the elton traits file.

species <- birds[which(birds$Scientific=='Cercomacra parkeri'),]

