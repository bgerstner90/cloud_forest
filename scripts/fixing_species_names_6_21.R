#Database parts 1 and 2
#Read in GBIF data for all mammals and birds in Colombia and Ecuador between elevations of 1000-3200
database_full_1 <- read.csv("/Volumes/GoogleDrive/My Drive/Cloud_forest_SROP/data/GBIF_data/fixed_names_GBIF/Final_GBIF_fixed_1.csv")
database_full_2 <- read.csv("/Volumes/GoogleDrive/My Drive/Cloud_forest_SROP/data/GBIF_data/fixed_names_GBIF/Final_GBIF_fixed_2.csv")

#combine both databases
database_full <- rbind(database_full_2, database_full_1)

#subset out unique species names 
database_full$Latin_name <- do.call(paste, c(database_full[c("genus", "specificEpithet")], sep = " ")) 

database_full_latin <- database_full$Latin_name

#make this into a dataframe
database_full_latin_df <- as.data.frame(database_full_latin)

#get unique names
unique_scientific_names <- unique(database_full_latin_df$database_full_latin)

#change to dataframe
GBIF_scientific_names <-as.data.frame(unique_scientific_names)

#add column name
colnames(GBIF_scientific_names)[1] <- "GBIF_scientific_names"

#Read in Elton trait data for the world
birds <- read.csv("/Users/bethgerstner/Desktop/MSU/Zarnetske_Lab/Data/Elton_Traits_birds_mammals/BirdFuncDat.csv",stringsAsFactors = FALSE)
mamm<- read.csv("/Users/bethgerstner/Desktop/MSU/Zarnetske_Lab/Data/Elton_Traits_birds_mammals/MamFuncDat.csv",stringsAsFactors = FALSE)
birds_mamm_elton <- merge.data.frame(mamm, birds, by= "Scientific", all=T)

#get unique names
unique_scientific_names_elton <- unique(birds_mamm_elton$Scientific)

#change to dataframe
elton_scientific_names <-as.data.frame(unique_scientific_names_elton)

#add column name
colnames(elton_scientific_names)[1] <- "elton_scientific_names"

#Read in IUCN data for Colombia and Ecuador
##have to run code ("IUCN_habitat_by_country") first
IUCN <-read.csv("/Users/bethgerstner/Desktop/MSU/Zarnetske_Lab/Data/IUCN_Data/habitat_by_species_fixed.csv", stringsAsFactors = FALSE)
IUCN_habitat <- merge.data.frame(co_ec_spp, IUCN, by= "taxonid")

#get unique names
unique_scientific_names_IUCN <- unique(IUCN_habitat$scientific_name)

#change to dataframe
IUCN_scientific_names <-as.data.frame((unique_scientific_names_IUCN),stringsAsFactors = FALSE)

#add column name
colnames(IUCN_scientific_names)[1] <- "IUCN_scientific_names"

#generating a species list
species_list <-database_full[!duplicated(database_full$Latin_name), ]


#retain only the columns we want
final_species_list <- species_list[c("Latin_name","kingdom","phylum", "order","family","genus","species","scientificName")]
write.csv(final_species_list, file="final_species_list.csv")
#removed species only identified to genus
final_species_list <-read.csv("/Users/bethgerstner/Desktop/species_list/final_species_list.csv")

no_match_IUCN <- as.data.frame(final_species_list$Latin_name[!final_species_list$Latin_name %in% IUCN_scientific_names$IUCN_scientific_names]) #1070 species don't match

#Species that are in the species list, but not in the elton database or IUCN database
no_match_elton <- as.data.frame(final_species_list$Latin_name[!final_species_list$Latin_name %in% elton_scientific_names$elton_scientific_names]) #238 species don't match
missing <- elton_scientific_names[which(elton_scientific_names$=='Aotus griseimembra'),]
write.csv(no_match_elton, file="missing_from_elton.csv")

#fix names
final_species_list$Latin_name[grep('Aglaiocercus kingii', final_species_list$Latin_name)] <- 'Aglaiocercus kingi'
final_species_list$Latin_name[grep('Aglaiocercus kingii', final_species_list$Latin_name)] <- 'Aglaiocercus kingi'

#create synonym column for species list
o_match <- ranges$Latin_name[!ranges$Latin_name %in% spp$Latin_Name_clean &
                               !ranges$Latin_name %in% spp$Latin_Name_synonym &
                               !ranges$Latin_name %in% spp$Latin_Name_synonym2]

match_elton_1 <- as.data.frame(final_species_list$Latin_name[final_species_list$Latin_name %in% elton_scientific_names$elton_scientific_names])
match_elton_12 <- subset(final_species_list, Latin_name %in% elton_scientific_names$elton_scientific_names)
match_elton_2 <- as.data.frame(final_species_list$Synonyms_1[final_species_list$Synonyms_1 %in% elton_scientific_names$elton_scientific_names])                               
match_elton_21 <- subset(elton_scientific_names, elton_scientific_names %in% final_species_list$Synonyms_1)
elton_species_list <- read.csv("/Users/bethgerstner/Desktop/species_list/species_list_match_elton.csv")
                               
write.csv(match_elton_21, file="species_list_match_elton_synonyms.csv")


setwd("/Users/bethgerstner/Desktop/species_list/Testing")

match_elton <- birds_mamm_elton[birds_mamm_elton$Scientific %in% final_species_list$Latin_name,]

GBIF_final <- database_full[elton_species_list$Latin_name %in% database_full$Latin_name,]
Elton_final <- birds_mamm_elton[birds_mamm_elton$Scientific %in% elton_species_list$Latin_name,]
write.csv(GBIF_final, file="GBIF_final_dataset_species_list.csv")
write.csv(Elton_final, file="Elton_final_dataset_species_lists.csv")

test_gbif<-database_full[match(database_full$Latin_name, elton_species_list$Latin_name), ]
test_elton<-birds_mamm_elton[match(elton_species_list$Latin_name, birds_mamm_elton$Scientific), ]

write.csv(test_gbif, file="Test_GBIF_final_dataset_species_list.csv")
write.csv(test_elton, file="Test_Elton_final_dataset_species_lists.csv")


subset_test_gbif <- subset(database_full, Latin_name %in% final_species_list$Latin_name)
subset_test_elton <- subset(birds_mamm_elton, Scientific %in% final_species_list$Latin_name)

#subset_test_gbif <- subset(final_species_list, Latin_name %in% database_full$Latin_name)
#subset_test_elton <- subset(final_species_list, Latin_name %in% birds_mamm_elton$Scientific)


GBIF_subset <- as.data.frame(subset_test_gbif)
gbif_unique <- unique(GBIF_subset$Latin_name)
gbif_unique_df <- as.data.frame(gbif_unique)
nrow(gbif_unique_df)



write.csv(subset_test_gbif, file="Final_GBIF_dataset_species_list.csv")
write.csv(subset_test_elton, file="Final_Elton_dataset_species_list.csv")

full_list_read.csv("/Users/bethgerstner/Desktop/species_list/Testing/species_list_match_elton_full.csv")



