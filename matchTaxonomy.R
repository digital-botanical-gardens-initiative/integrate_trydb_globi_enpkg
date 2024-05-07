#################################################################################################
# @Project - TRY-db data integration with ENPKG							#
# @Description - This code integrates taxonomy mapping of species name 				#
#		 from TRY-db (ott, wikidata, gbif, ncbi)					#
#################################################################################################

library(rotl)
library(taxizedb)
library(dplyr) 
library(dbplyr)
library(duckdb)
library(arrow) #optional. Yet to decide its applicability

wdir <- "data"
#get data from OTOL
getOtol <- function(df.speciesX) {
	a1 <- unique(df.speciesX$TRY_AccSpeciesName)
	a1 <- tolower(a1)
	#window of 10000 as listed in the description of tnrs_match_names
	df.otol <- tnrs_match_names(names = a1[1:5663],context_name="Land plants")
	for (i in seq(5664,length(a1),10000)) {
        	j <- i + 9999
	        print("In progress....")
 	        df.tmp <- tnrs_match_names(names = a1[i:j],context_name="Land plants")
        	df.otol <- rbind(df.otol, df.tmp)
	}
	which(!(a1 %in% df.otol$search_string))
	#there are some duplicates, and 23265 names which were not found. In testing phase to figure out an alternative approach for mapping those 23265 names
	df.otol <- na.omit(df.otol) #Omit all those that were not found
	return(df.otolX)
}

#get data from wikidata and subsequent gbif and ncbi ids
getWikidata <- function() {
	db_download_wikidata(verbose = TRUE, overwrite = FALSE) # download wikidata with aggregated taxonomic ids for ncbi and gbif.
	db_path("wikidata") # get the path of the database. optional.
	src <- src_wikidata()  # load wikidata
	df.wikidataX <- data.frame(tbl(src, "wikidata"))
	#sanity check
	x <- filter(df.wikidataX, scientific_name == "Acer campestre")
	print(x)
	return(df.wikidataX)
}

#open TRY db, get the species name############
df.species <- read.csv(paste(wdir,"Try20243712146549_TRY6.0_SpeciesList_TaxonomicHarmonization.csv", sep="/"), header=TRUE, sep=",",row.names=NULL)
#df.species.search <- df.species[,c("TRY_AccSpeciesName","TRY_AccSpeciesID")]

#mapping to wikidata, ncbi, gbif and otol 
df.wikidata <- getWikidata() # Used for taxonomic mapping. It also maps to gbif, and ncbi
df.otol <- getOtol(df.species) # ott mapped separately
write.csv(df.otol,paste(wdir,"Taxonomic_mapping_trydb_otol.csv",sep="/"))

#match try species data to wikidata and ott taxon names, receive the final table 'taxonomy' to be used in the KG
df.result.left <- left_join(df.species,df.wikidata, by=c("TRY_AccSpeciesName"="scientific_name"), relationship="many-to-many")
df.result.left <- left_join(df.result.left,df.otol[,c("unique_name","ott_id")], by=c("TRY_AccSpeciesName"="unique_name"), relationship="many-to-many")
write.csv(df.result.left,paste(wdir,"TRYdbSpecies-mapped_with-wd-ncbi-gbif-otol.csv",sep="/"))

#open trait data from TRY-db################## In testing
#the following 3 lines need to be run only once, to install the sqlite extension for duckdb-r
#con <- DBI::dbConnect(duckdb(config=list('allow_unsigned_extensions'='true')))
#dbExecute(con, "INSTALL sqlite") 
#dbExecute(con, "LOAD sqlite") 


