export LC_ALL=C

# find all unique wikidata ids in TRYdb.
awk -F "\t" '{if (NR != 1 && $(NF-5) != "NA") print $(NF-5)}' data/duckdb_input/taxonomy.csv | sort -u | sed 's/\"//g' > data/TRYdbSpecies-wd-unique.txt

# find wikidats ids for all source and target species in GLOBI db
wget data/globi/interactions.csv.gz https://zenodo.org/record/8284068/files/interactions.csv.gz #download interactions data from GLOBI
gunzip -c data/globi/interactions.csv.gz | awk -F "," '{print $2"\t"$42}' | grep -o "WD:[A-Z0-9]\+" | sed 's/WD://' | sort -u > data/globi/source2_target42_TaxonIDs.txt #for getting the wikidata ids for source (2) and target (42) columns.

#find unique wikidata ids between TRYdb and GLOBI db
cat data/TRYdbSpecies-wd-unique.txt data/globi/source2_target42_TaxonIDs.txt | sort | uniq -c | grep "^\s\+2" | sed 's/^\s\+2 //g' > data/globi/common_wd_ids_TRY_GLOBI.txt


#The following command will match the 13858 wikidat IDs fast (5 mins) to the 21358086 records in interactions.csv 
cat data/globi/common_wd_ids_TRY_GLOBI.txt | parallel --pipe -L1000 -j 4 --result data/globi/all_12849 zgrep -f - -n data/globi/interactions.tsv.gz

gunzip -c data/globi/interactions.tsv.gz | head -1 > data/globi/headIntxns.csv


# move and rename files
#cat data/globi/headIntxns.csv data/globi/all_12849/stdout | sed 's/"\(Faspuszta\)[":]/\1/g' > integrate_trydb_globi_enpkg_data/globi/intxns_TRYdb_globi_12849.csv # Not a problem only in Plantae kingdom
#sed -i 's/"\(Faspuszta\)[":]/\1/g' integrate_trydb_globi_enpkg_data/globi/intxns_TRYdb_globi_12849.csv #not a problem if only Plantae kingdom
cat data/globi/headIntxns.csv data/globi/all_12849/stdout > data/globi/intxns_TRYdb_globi_12849.csv 
pigz data/globi/intxns_TRYdb_globi_12849.csv
rm -r data/globi/all_12849

