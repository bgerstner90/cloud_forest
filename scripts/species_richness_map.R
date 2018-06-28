# Function to convert a spatialpointsdataframe object (point_object) with a species ID column name into a gridded richness raster
# The other arguments are the extent, the resolution (in degrees), and a file name.
# QDR / 26 June 2018

count_richness <- function(point_object, column_name, x_min = -125, x_max = -67, y_min = 25, y_max = 50, resolution = 0.2, file_name) {
  
  require(raster)
  # Default is to define empty raster with a box containing the lower 48 and 0.2 degree (~20km) resolution
  us <- raster(xmn = x_min, xmx = x_max, ymn = y_min, ymx = y_max)
  projection(us) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  res(us) <- resolution
  
  # Count number of overlapping polygons in every cell of the empty us raster, and fill in those values
  us <- rasterize(point_object, us, field = column_name, fun = fun=function(x, ...) {length(unique(na.omit(x)))})
  
  # Save raster for drawing map later
  writeRaster(us, filename = file_name, format = 'GTiff')
  cat('Raster written to', file_name)
}