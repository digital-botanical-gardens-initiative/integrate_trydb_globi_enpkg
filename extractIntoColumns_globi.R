library(tidyverse)

categories <- "data/globi/categories.txt"
file1 <- "data/globi/intxns_TRYdb_globi_12849.csv.gz"

catg <- read.csv(categories, sep = "\t", header=FALSE, row.names = NULL)
fN <- data.frame(read.csv(gzfile(file1), sep = "\t", quote= "", header=TRUE, row.names = NULL)) #no empty lines

# function to separate pipe delimited field to categories
extr  <- function(catg,fx2) {
	for(i in 1:nrow(catg)) {
		print(catg[i,])
		m <- gregexec(paste(catg[i,],"[A-Z0-9]+", sep=""), fx2[,1])
		res <- regmatches(fx2[,1],m)
		cols <- unique(unlist(res))                           # unlist to remove nested lists
		res1 <- data.frame(map_vec(res, ~ifelse(is.null(.x), NA, .x)))
		names(res1) <- catg[i,]
                res1 <- as.data.frame(sub(catg[i,],"",res1[,1]))
		names(res1) <- catg[i,]
		ifelse(i==1, res2 <- res1, res2 <- cbind(res2,res1))


	}
	return(res2)
}

# extract source taxon ids
fN2.res <- extr(catg,data.frame(Ids=fN[,2]))
names(fN2.res) <- c("source_BOLD","source_COL","source_ENVO","source_EOL","source_FB","source_FBC","source_GBIF","source_IF","source_IRMNG","source_ITIS","source_NBN","source_NCBI","source_PBDB","source_SLB","source_SPECCODE","source_TAXON","source_W","source_WD","source_WORMS")
#names(fN2.res) <- c("source_BOLD","source_COL","source_ENVO","source_EOL","source_FB","source_FBC","source_GBIF","source_IF","source_IRMNG","source_ITIS","source_NBN","source_NCBI","source_PBDB","source_SLB","source_SPECCODE","source_TAXON","source_W","source_WD","source_WORMS","source_biodiversity.org","source_openbiodiv.net","source_treatment.plazi","source_boldsystems.org")
#write.csv(fN2.res, "fN2.res.txt")

# extract target taxon ids
fN42.res <- extr(catg,data.frame(Ids=fN[,42]))
names(fN42.res) <- c("target_BOLD","target_COL","target_ENVO","target_EOL","target_FB","target_FBC","target_GBIF","target_IF","target_IRMNG","target_ITIS","target_NBN","target_NCBI","target_PBDB","target_SLB","target_SPECCODE","target_TAXON","target_W","target_WD","target_WORMS")
#names(fN42.res) <- c("target_BOLD","target_COL","target_ENVO","target_EOL","target_FB","target_FBC","target_GBIF","target_IF","target_IRMNG","target_ITIS","target_NBN","target_NCBI","target_PBDB","target_SLB","target_SPECCODE","target_TAXON","target_W","target_WD","target_WORMS","target_biodiversity.org","target_openbiodiv.net","target_treatment.plazi","target_boldsystems.org")
fNFinal.res <- cbind(fN2.res,fN42.res)
cols <- c(1,3:41,43:ncol(fN))
fN <- fN[,cols]
fN <- cbind(fN,fNFinal.res)
#write.csv(fNFinal.res, "fNFinal.intxn.txt")

write.table(fN, file=gzfile("data/duckdb_input/intxns.csv.gz"),sep="\t",row.names=FALSE)

#save.image(file='extractIntoColumns_globi_session.RData')

