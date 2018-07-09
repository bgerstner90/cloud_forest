## Calculating suitable area for the Andean Bear that is also protected by national parks 
## and private reserves.

## By: Beth E. Gerstner

# Read in raster of prediction for Andean bear

and.pred <- read.csv("put path in here")

# Thresholded the resampled prediction by the Minimum Training Presence
bin_pred <-  resampled_pred >= type the threshold value
plot(bin_pred)

writeRaster(bin_pred, "C:/Users/Beth/Desktop/New folder/bin_pred.tif")

# Crop the bear prediction to colombia and ecuador 
bin_pred_crop <- mask(bin_pred, PUT THE SMALL CLIPPED ENV RAStER IN HERE)

#read in shapefile of national parks

parks <- readOGR(" path", "file name")

#clip the prediction by the national parks shapefile

protect_bin_pred <- mask(bin_pred_crop, parks)

#finding area both suitable climatically and protected
suit_protected <- ncell(protect_bin_pred[protect_bin_pred==1]) #gets all cells suitable (=1)

# suitable for the bear in colombia and ecuador 
suitable_all <- ncell(bin_pred_crop[bin_pred_crop==1]) #gets all cells suitable (=1)

#Percent suitable that is protected
per_clim_forest <- suit_protected/suitable_all

_________________________________________________________________________________________________
###Comparison of suitable and forested areas in  Colombia

# Climatically suitable area in colombia (clipped in ArcGIS)
clim_suit_colom <- raster("C:/Users/Beth/Desktop/New folder/split_country_stats/colombia_climatically_suitable1.tif")
clim_suit_colom_cell <- ncell(clim_suit_colom[clim_suit_colom==1]) #gets all cells suitable (=1)
clim_colombia <- clim_suit_colom_cell *0.053633479
[1] 88,677.59 km^2 #area suitable abiotically 

# Climatically suitable and forested area in colombia (clipped in ArcGIS)
clim_suit_DTT_colom <- raster("C:/Users/Beth/Desktop/New folder/split_country_stats/colombia_suitable_forested1.tif")
clim_suit_colom_cell <- ncell(clim_suit_DTT_colom[clim_suit_DTT_colom==1]) #gets all cells suitable (=1)
clim_dtt_colombia <- clim_suit_colom_cell *0.053633479
[1] 40,902.18 km^2 #area suitable abiotically and forest cover

#Percent climatically suitable area forested above the DTT for Colombia
per_clim_forest_colom <- clim_dtt_colombia/clim_colombia
[1] 0.4612459
