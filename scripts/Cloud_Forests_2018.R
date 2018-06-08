# Title: Merging & Data Cleaning for Cloud Forests Project
# Authors: Cameo Chilcutt, Beth Gerstner, Krymsen Hernandez
# Date: 6 June 2018

setwd("G://My Drive//Cloud_forest_SROP//data")
rm(list = ls())

#Read in Elton Traits dataset 
birds <- read.csv(".//elton_traits//bird_mammal_data//BirdFuncDat.csv")
mamm<- read.csv(".//elton_traits//bird_mammal_data//MamFuncDat.csv")

#Read in IUCN data
all_birds <-read.csv(".//IUCN_data//birds_IUCN.csv")
all_mammals <-read.csv(".//IUCN_data//mammals_IUCN.csv")
all_habitat<-read.csv(".//IUCN_data//habitat_by_species.csv")

#Combine bird elton traits dataset and IUCN bird data together
colnames(birds)[which(names(birds) == "Scientific")] <- "scientific_name"
bird_trait_IUCN<- merge.data.frame(birds, all_birds, by= "scientific_name", all=T)

write.csv(bird_trait_IUCN, 'Birds.csv')

#Combine mammal elton traits dataset and IUCN bird data together
colnames(mamm)[which(names(mamm) == "Scientific")] <- "scientific_name"
mamm_trait_IUCN <- merge.data.frame(mamm, all_mammals, by= "scientific_name", all=T)

write.csv(mamm_trait_IUCN, 'Mammals.csv')

#Merge each taxon dataset by taxonid to have a comprehensive list of functional traits, IUCN statuses, and habitat types
bird_trait_IUCN_habitat <- merge.data.frame(bird_trait_IUCN, all_habitat, by= "taxonid", all=T)
write.csv(bird_trait_IUCN_habitat, 'complete_IUCN_trait_birds.csv')

mamm_trait_IUCN_habitat <- merge.data.frame(mamm_trait_IUCN, all_habitat, by= "taxonid", all=T)
write.csv(mamm_trait_IUCN_habitat, 'complete_IUCN_trait_mammals.csv')

library(dplyr)
All_Data <- bind_rows(bird_trait_IUCN_habitat, mamm_trait_IUCN_habitat)

#Omitting NAs for scientific_name column
All_Data<-All_Data[!is.na(All_Data$scientific_name),]
All_Data
write.csv(All_Data, 'All_Data_NoNA.csv')

#Keeps only the species name and categorical diet type
birds1 <- birds[,c(8, 10:21)]

####################################################################################################################
