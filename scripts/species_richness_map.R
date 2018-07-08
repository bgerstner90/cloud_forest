# Function to convert a spatialpointsdataframe object (point_object) with a species ID column name into a gridded richness raster
# The other arguments are the extent, the resolution (in degrees), and a file name.
# QDR / 26 June 2018
occ2 <- read.csv("/Users/bethgerstner/Desktop/IUCN_Gbif_reduced_2.csv")
occ1 <- read.csv("/Users/bethgerstner/Desktop/IUCN_Gbif__reduced_1.csv")

occ.all <- merge(occ2, occ1, all.x=TRUE, all.y=TRUE)
occ.all.coord <- occ.all[,c("lat","long","scientific_name")]

occ.all.sp <- SpatialPointsDataFrame(occ.all.coord[,c(1,2)], as.data.frame(occ.all.coord[,1:3]))

count_richness <- function(occ.all.sp, scientific_name, x_min = -95, x_max = -65, y_min = 30, y_max = 15, resolution = 0.2, file_name) {
  
  library(raster)
  # Default is to define empty raster with a box containing the lower 48 and 0.2 degree (~20km) resolution
  sa <- raster(xmn = x_min, xmx = x_max, ymn = y_min, ymx = y_max)
  projection(sa) <- "+proj=latlong +ellps=WGS84 +datum=WGS84 +no_defs"
  res(sa) <- resolution
  
  # Count number of overlapping polygons in every cell of the empty us raster, and fill in those values
  sa <- rasterize(occ.all.sp, sa, field = 'scientific_name', fun = fun=function(x, ...) {length(unique(na.omit(x)))})

# Save raster for drawing map later
writeRaster(sa, filename = "file_name", format = 'GTiff')
cat('Raster written to', file_name)

}
setwd("/Users/bethgerstner/Desktop/richness_test")
