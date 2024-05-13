#################################################################################################
# @Project - TRY-db data integration with ENPKG							#
# @Description - This code gives the distribution of taxonomy mapping of species name 		#
#		 from TRY-db (ott, wikidata, gbif, ncbi)					#
#		Followed by 'matchTaxonomy.R'							#
#################################################################################################

library(ggplot2)

#args <- commandArgs(trailingOnly=TRUE)
#file <- args[1]
file <- "data/duckdb_input/taxonomy.csv"

#Tip: read.csv always works with csv files. read.table is tricky to use with csv files, because of its weird behaviour for treating quotes. Even after changing the quotes to the desired beahviour, it didn't wrk with read.table. csv files are preferred in this case because there are full citations inside the document.
tax <- read.csv(file, sep=",", header=TRUE, row.names = NULL) 

ott <- na.omit(tax[which(tax$ott_id != ""),c("AccSpeciesID","ott_id")])
gbif <- na.omit(tax[which(tax$gbif_id != ""),c("AccSpeciesID","gbif_id")])
ncbi <- na.omit(tax[which(tax$ncbi_id != ""),c("AccSpeciesID","ncbi_id")])
wd <- na.omit(tax[which(tax$wikidata_id != ""),c("AccSpeciesID","wikidata_id")])
all <- na.omit(tax[which(tax$wikidata_id != "" & tax$ncbi_id != "" & tax$gbif_id != "" & tax$ott_id != ""),c("AccSpeciesID","wikidata_id","gbif_id","ncbi_id","ott_id")])
df <- data.frame(db = c("gbif","ncbi","ott","wd", "all_db"), num = c(nrow(gbif), nrow(ncbi), nrow(ott), nrow(wd), nrow(all)))

p <- ggplot(data = df, aes( x = db, y = num)) + geom_bar(stat = "identity", fill="steelblue") + theme(text=element_text(size=30))
png(paste("figures","distributionDB.png",sep="/"))
print(p)
dev.off()
