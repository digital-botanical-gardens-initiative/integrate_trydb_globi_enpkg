This repository contains scripts for integrating species and subsequent traits data from trydb with taxonomic ids from gbif, otol, ncbi and wikidata. Data for only 25 traits was downloaded from TRY-db. Subsequently, the traits metadata was retrieved from TRY-db website and a subset of enpkg was also retrieved. The csv file for interactions was retrieved from [GLOBI database](https://www.globalbioticinteractions.org/data). The csv files retrieved were converted to duckdb (adavantge: on-disk approach for sql queries). 

Download the datasets used in this repo from [zenodo](https://zenodo.org/doi/10.5281/zenodo.11186592).

The TRY-db dataset with 25 traits has multiple columns, which are related as depicted in the diagram below.
![TryDbAll_relationsExplained](https://github.com/digital-botanical-gardens-initiative/integrate_trydb_globi_enpkg/blob/master/figures/TryDbAll_relationsExplained_20240502.png?raw=true)



**I. Prerequisites:**

For smooth running of the scripts (R,shell), install R (version 4.1.2) and the following R-packages as well as some other softwares:

 a) For accessing taxonomic ids from wikidata, with mappings from gbif and ncbi (taxizedb) and from open treel of life (rotl)
`install.packages(c("taxizedb", "rotl"))`

 b) For data manipulation, install dplyr and dbplyr (backend wrapper to convert dplyr code into SQL)
`install.packages(c("dplyr", "dbplyr"))`

 c) For the on-disk approach of accessing and querying databases, duckdb's API client for R
`install.packages("duckdb")`

 and [duckdb](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=linux&download_method=package_manager)

 d) For building a Virtual Knowledge Graph (VKG), download [Ontop-cli/Ontop-protege bundle (version 5.1.2)](https://github.com/ontop/ontop/releases/tag/ontop-5.1.2)

 e) For converting ontology files between multiple formats (e.g.: owl to ttl), install [robot](https://github.com/ontodev/robot/releases/tag/v1.9.5).



**II. Script to map the TRY plant species name to the gbif, ncbi, wikidata and otol ids**

`Rscript matchTaxonomy.R`

To plot distribution of the TRY-db species matched with ids from ott, ncbi, gbif and wikidata, run

`Rscript distTaxonomicIds.R`

![distributionDB](https://github.com/digital-botanical-gardens-initiative/integrate_trydb_globi_enpkg/blob/master/figures/distributionDB.png?raw=true)


**III. Script to build a duckdb database for Ontop and build the knowledge graph**

`sh run_duckdb.sh`

The relations between tables are depicted in the following minimal ER diagram. The full diagram can be found in the file 'figures/TableRelations_ER_diagram_full.png'
![TableRelations_truncated_20240513](https://github.com/digital-botanical-gardens-initiative/integrate_trydb_globi_enpkg/blob/master/figures/TableRelations_truncated_diagram.png?raw=true)




**IV. Script to extract common wikidata ids between TRY-db and GLOBI, followed by retrieveing pair-wise interaction data from GLOBI for those ids**

`sh run_ext_com_GLOBI_TRY.sh`


Note that the above requires downloading interactions.csv.gz from [GLOBI database](https://www.globalbioticinteractions.org/data)

**V. Script to convert clubbed ids in file from step V to individual columns**

`Rscript extractIntoColumns_globi.R`


**VI. Script to build the knowledge graph in Ontop**   
`#Set the path in data/Ontop_config/duckdb.properties` 

`sh run_ontop.sh`


Note: This step is still in development and faulty.


**VII. Disclaimer**

The mappings in the ontop virtual knowledge graph are faulty at the moment. Therefore, the SPARQL query does not result in correct results. Work in progress...
