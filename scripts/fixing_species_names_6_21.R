#Read in GBIF data for all mammals and birds in Colombia and Ecuador between elevations of 1000-3200

database_full <- read.csv("/Users/bethgerstner/Documents/GBIF_fixed/bird_mammal_elev_subset.csv", stringsAsFactors = FALSE)

#subset out uniqure species names 

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

no_match_IUCN <- as.data.frame(final_species_list$Latin_name[!final_species_list$Latin_name %in% IUCN_scientific_names$IUCN_scientific_names]) #1070 species don't match

#Species that are in the species list, but not in the elton database or IUCN database
no_match_elton <- as.data.frame(final_species_list$Latin_name[!final_species_list$Latin_name %in% elton_scientific_names$elton_scientific_names]) #435 species don't match
missing <- elton_scientific_names[which(elton_scientific_names$elton_scientific_names=='Aglaiocercus kingi'),]


#fix names
final_species_list$Latin_name[grep('Aglaiocercus kingii', final_species_list$Latin_name)] <- 'Aglaiocercus kingi'
final_species_list$Latin_name[grep('Aglaiocercus kingii', final_species_list$Latin_name)] <- 'Aglaiocercus kingi'

#create synonym column for species list



