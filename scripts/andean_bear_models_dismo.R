## This code is to generate SDMs for the Andean Bear as part of the SROP summer program.
## Here we process occurrence records obtained from GBIF, filter by distance to remove sampling biases, create an appropriate 
## study area and use dismo to generate an SDM for the species.
## By: Beth Gerstner

library(ENMeval)
library(rgeos)
library(dismo)
library(rgdal)
library(raster)
library(spThin)


##Thinning by 10km using library(spThin)

setwd("C:/GIS/Andes/olinguito/Beth/georef_occur_summer15")

# Read in all occurrence points from GBIF and thin them by 10km
occ <- read.csv("C:/GIS/Andes/olinguito/Beth/georef_occur_summer15/localities_csv.csv")
occ.t <- thin(occ, lat.col = "lat", long.col = "long", spec.col = "species",
              thin.par=10, reps=1000, locs.thinned.list.return = TRUE, write.files=FALSE)
sapply(occ.t, nrow) # visually inspected the outputs to see how many records retained in each
max(sapply(occ.t, nrow))  # check what max number of output thinned records is
occ <- occ.t[[1]]  # assign thinned records to first dataset because all had 16 records
##File used for analysis: occ <- read.csv("/Volumes/BETH'S DRIV/Anderson_Lab_Archive/georef_occur_summer15/10km_thin/thinned_data_thin1.csv") 
occ.sp <- SpatialPointsDataFrame(occ[c(1,2)], as.data.frame(occ[,1])) #Makes into spatial object

# Set working directory to folder where environmental data is stored 
setwd("/Volumes/BETH'S DRIV/Anderson_Lab_Archive/Worldclim/Full")

# Making stack of all 19 bioclimatic variables
env <- list.files(pattern='bil', full.names=TRUE)
# env <-env[-16]
env <- stack(env)

## Crop extent to a smaller region so it is easier to work with
# 5 degree bounding box buffer around occurrence records
extentlarge <- gBuffer(occ.sp, width=5)
# Crop and mask environmental variables by the larger extent
env_crop <- crop(env, extentlarge)
env_msk <- mask(env_crop, extentlarge)
env_msk
plot(env_crop[[1]])
plot(env_msk[[1]])
points(occ.sp, col="red", cex=0.6)

# Generate 0.7 degree buffered 'crop circle' around occurrence points
backg_extent <- gBuffer(occ.sp, width=0.7)
# Crop and mask environmental variables by the 'crop circle' extent
env_crop_bg <- crop(env_msk, backg_extent)
env_msk_bg <- mask(env_crop_bg, backg_extent)
plot(env_msk_bg[[1]])

# Generate background points within the defined study region (sampled without replacement)
# Maxent also samples without replacement
# set.seed(1) generates the same random points every time we run the code
set.seed(1)
backg.env <- randomPoints(env_msk_bg[[1]], n=10000, excludep=FALSE)

#_________________________________________________________________________________________
##Model Tuning (choosing the best predictive model)

setwd("C:/Users/Beth/Desktop/ENM_eval")
# ENMeval using written background coordinates
Jackknife_results <- ENMevaluate(occ2, env_crop, bg.coords = backg.env, 
                                 RMvalues = seq(0.5, 4, 0.5), 
                                 fc = c("L", "LQ", "LQH", "H"),
                                 method = 'jackknife', parallel=TRUE)

# Calls results table
x <- Jackknife_results@results

# Write results table to a file
setwd("C:/GIS/Andes/olinguito/Beth/summer15_models/ENMeval_results_table/ENMeval_stats_run8_cropc_ncc_10km_.7")
write.csv(x, file="ENMeval_results.csv")

# Subsets data with the lowest omission rate for MTP (Vetted by M. Gavrutenko comparing with a sorted Excel file)
minORs <- x[which(x$Mean.ORmin == min(x$Mean.ORmin)),]
write.csv(minORs,file="ENMeval_MTP_OR.csv")

# Takes previous subset and choses model with the highest average test AUC (Vetted by M. Gavrutenko comparing with a sorted Excel file)
maxAUC.mtp <- minORs[which(minORs$Mean.AUC == max(minORs$Mean.AUC)),]
write.csv(maxAUC.mtp,file="ENMeval_MTP_OR_max_AUC.csv")

# Same as previous, but with the 10%OR
ORs <- x[which(x$Mean.OR10 == min(x$Mean.OR10)),]
write.csv(ORs,file="ENMeval_OR_10.csv")

# Same as previous, but with the 10%OR
maxAUC.x10 <- ORs[which(ORs$Mean.AUC == max(ORs$Mean.AUC)),]
write.csv(maxAUC.x10,file="ENMeval_OR_10_max_AUC.csv")

# minimize AICc
# evaluated the lowest AICc value by visually inspecting an Excel file.Next time, run next line instead.
minAIC <- x[which(x$delta.AICc == 0),] #Make sure the column is delta.AICc
write.csv(minAIC,file="ENMeval_min_AIC.csv")

## Validated that this code produced the optimal settings, via human inspection of Excel file of ENMeval output
#Best model H3 via sequential criteria (Lowest OR and Highest AUC)
#Best model LQ1 via AICc


#______________________________________________________________________________________
## MODEL BUILDING IN DISMO
# DISMO run for LQ1

# project optimal (min AICc model) to the larger extent and save raster as TIFF
opt.aic <- Jackknife_results@models[[6]]
pred.aic1 <- predict(opt.aic, env_crop, filename="largeprojection_AIC.tif1")

# project optimal (min OR, max test AUC model) to the larger extent and save raster as TIFF
opt.seq <- Jackknife_results@models[[24]]
pred.seq <- predict(opt, env_crop, filename="largeprojection_maxAUC.tif")





