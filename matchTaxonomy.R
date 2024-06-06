#################################################################################################
# @Project - TRY-db data integration with ENPKG							#
# @Description - This code integrates taxonomy mapping of species name 				#
#		 from TRY-db (ott, wikidata, gbif, ncbi)					#
#################################################################################################

library(rotl) #NI
library(taxizedb)
library(dplyr) 
library(dbplyr)
library(tidyverse) #couldn't install correctly
library(arrow) #optional. Yet to decide its applicability #NI
library(igraph)


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
	#dbDisconnect()
	return(df.otolX)
}

#get data from wikidata and subsequent gbif and ncbi ids
getWikidata <- function() {
	db_download_wikidata(verbose = TRUE, overwrite = FALSE) # download wikidata with aggregated taxonomic ids for ncbi and gbif.
	db_path("wikidata") # get the path of the database. optional.
	src <- src_wikidata()  # load wikidata
	df.wikidataX <- data.frame(tbl(src, "wikidata"))
	#sanity check
	#x <- filter(df.wikidataX, scientific_name == "Acer campestre")
	#print(x)
	#dbDisconnect()
	return(df.wikidataX)
}

getGbif <- function() {
	db_download_gbif(verbose = TRUE, overwrite = FALSE) # download gbif
	db_path("gbif") # get the path of the database. optional.
	src <- src_gbif()  # load gbif
	df.gbifX <- data.frame(tbl(src, "gbif"))
	df.gbifX <- df.gbifX[which(df.gbifX$kingdom=="Plantae"),]
	#sanity check
	#x <- filter(df.gbifX, scientific_name == "Acer campestre")
	#print(x)
	#dbDisconnect()
	return(df.gbifX)
}

dfs_traversal1 <- function(graph, start_node) {
  dfs_result <- dfs(graph, root = start_node, dist = TRUE)
  return(dfs_result$order) # Return the order of visited nodes
}

extr  <- function(catg,fx2) {
        for(i in 1:length(catg)) {
                print(catg[i])
                m <- gregexec(paste(catg[i],"[A-Z0-9]+", sep=""), fx2[,1])
                res <- regmatches(fx2[,1],m)
                res1 <- data.frame(map_vec(res, ~ifelse(is.null(.x), NA, .x)))
                names(res1) <- sub(":","",catg[i])
		res1 <- as.data.frame(sub(catg[i],"",res1[,1]))
                names(res1) <- sub(":","",catg[i])
                ifelse(i==1, res2 <- res1, res2 <- cbind(res2,res1))
        }
        return(res2)
}

#set working directory
wdir <- "data"

#open TRY db, get the species name############
df.species <- read.csv(paste(wdir,"Try20243712146549_TRY6.0_SpeciesList_TaxonomicHarmonization.csv", sep="/"), header=TRUE, sep=",",row.names=NULL)

#mapping to wikidata, ncbi, gbif and otol 
df.wikidata <- getWikidata() # Used for taxonomic mapping. It also maps to gbif, and ncbi

#for mapping lineage of wikidata ids. TBD
#g <- graph_from_data_frame(df.wikidata[,c("wikidata_id","parent_id")], directed = TRUE)
#cat("DFS Traversal starting for all nodes in wikidata\n")
#dfs_order <- dfs_traversal(g, 'Q12824168')
#print(V(g)$name[dfs_order])

df.gbif <- getGbif() # Used for taxonomic mapping. It also maps to gbif, and ncbi
#df.otol <- getOtol(df.species) # ott mapped separately. not included in the taxonomy file as of now.
#write.csv(df.otol,paste(wdir,"Taxonomic_mapping_trydb_otol.csv",sep="/"))

#match try species data to wikidata and ott taxon names, receive the final table 'taxonomy' to be used in the KG
#WD
catg <- c("NCBI:","GBIF:")
res3 <- extr(catg, data.frame(ids=df.wikidata$external_ids))
df.wikidata <- cbind(df.wikidata,res3)
write.csv(res3, paste(wdir, "Tax_trydb_wd_gbif.csv", sep="/"))

df.result.wd <- left_join(df.species,df.wikidata, by=c("TRY_AccSpeciesName"="scientific_name"), relationship="many-to-many") ## wd
df.result.wd$GBIF <- as.numeric(as.character(df.result.wd$GBIF))
df.result.wd$NCBI <- as.numeric(as.character(df.result.wd$NCBI))
write.csv(df.result.wd, paste(wdir, "Tax_trydb_wd.csv", sep="/"))




#GBIF
df.result.gbif <- left_join(df.species,df.gbif, by=c("TRY_AccSpeciesName"="canonicalName"), relationship="many-to-many") ## gbif
length(which(df.species$TRY_AccSpeciesName %in% df.result.gbif$TRY_AccSpeciesName)) #check how many of the TRY db species are in the gbif
length(unique(df.species$TRY_AccSpeciesName)) #305663
length(unique(df.result.gbif[which(is.na(df.result.gbif$genus)==1),"TRY_AccSpeciesName"])) #check how many species are not covered by gbif #29297 out of 305663
length(unique(df.result.gbif[which(is.na(df.result.gbif$genus)==0),"TRY_AccSpeciesName"])) #check how many species are covered by gbif #276366 out of 305663
write.csv(df.result.gbif, "Tax_trydb_gbif.csv")

#ott not included yet in the taxonomy file
#df.result.left <- left_join(df.result.left,df.otol[,c("unique_name","ott_id")], by=c("TRY_AccSpeciesName"="unique_name"), relationship="many-to-many")


xGBIF <- unique(df.result.gbif$taxonID) 
df.finalResult <- df.result.wd[which(df.result.wd$GBIF %in% xGBIF),] 
write.table(df.finalResult, paste(wdir, "TRYdbSpecies-mapped_with-wd-ncbi-gbif.csv",sep="/"), row.names=FALSE, sep="\t")


#temporary code to be retained for future.
#df.result.gbif.wd <- left_join(df.result.gbif,df.result.wd, by=c("taxonID"="GBIF"), relationship="many-to-many") #this is wrong because you are matching ll against all
#write.csv(df.result.left,paste(wdir,"TRYdbSpecies-mapped_with-wd-ncbi-gbif-otol.csv",sep="/"))
#the following 3 lines need to be run only once, to install the sqlite extension for duckdb-r
#con <- DBI::dbConnect(duckdb(config=list('allow_unsigned_extensions'='true')))
#dbExecute(con, "INSTALL sqlite") 
#dbExecute(con, "LOAD sqlite") 


