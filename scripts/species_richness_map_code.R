# Function to create gridded species richness maps based on code found here: http://vegetationsciencetools.blogspot.com/2014/06/mapping-species-richness-in-cells-based.html.

By:Beth E. Gerstner

require(raster)

#read in occurrence records of all co-occurring species
spp_records <- occ.all[,c("lat","long","scientific_name")] #create a data frame simulating 2000 spatial records of the 100 simulated species within a predetermined spatial area - numbers under 'value' are in this case factors representing unique species from the above pool of 100 

#set to spatial points data frame object by highlighting the latitude and longitude columns
coordinates(spp_records) <- c(1,2) 

# plot as points to visualise where the records were made
plot(spp_records, pch=20, cex=0.5) 

#now recreate, but truncate the coordinates to a regular grid at 0.1 degrees resolution
spp_records <- data.frame(latitude=round(spp_records$lat, digits=1), longitude=round(spp_records$long, digits=1), value=spp_records$scientific_name) 
coordinates(spp_records) <- c(1,2)

# simple function to count the number of unique 'species' (factor levels)
rich_count <- function(x) length(unique(x))

#count the number of unique species that have the same truncated coordinates
richness <- aggregate(spp_records$value, list(spp_records$latitude, spp_records$longitude), rich_count) 

#set coordinates
coordinates(richness) <- c(2,1) 

#create a gridded map (at 0.1 resolution) with values as the number of unique species recorded in that cell
richness2 <- rasterFromXYZ(richness) 

#set the projection for plotting
projection(richness2) <- "+proj=longlat +ellps=WGS84" 

# cell-based 'species richness' map
plot(richness2, col=rev(heat.colors(max(richness$x)))) 

writeRaster(richness2, "insert path here with filename.tif" )

#you can also play around with a moving window type add-on, in this case averaging the richness scores 
#for a given cell using the surrounding set of cells, to even out idiosyncrasies of how records are assigned to one cell or another
#plot(focal(richness2, w=matrix(1,3,3), fun=mean, na.rm=TRUE), col=rev(heat.colors(max(richness$x)))) 






