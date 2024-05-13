


CREATE TABLE trydbAll(LastName VARCHAR, FirstName VARCHAR, DatasetID VARCHAR, Dataset VARCHAR, SpeciesName VARCHAR, AccSpeciesID VARCHAR, AccSpeciesName VARCHAR, ObservationID VARCHAR, ObsDataID VARCHAR, TraitID VARCHAR, TraitName VARCHAR, DataID VARCHAR, DataName VARCHAR, OriglName VARCHAR, OrigValueStr VARCHAR, OrigUnitStr VARCHAR, ValueKindName VARCHAR, OrigUncertaintyStr VARCHAR, UncertaintyName VARCHAR, Replicates VARCHAR, StdValue VARCHAR, UnitName VARCHAR, RelUncertaintyPercent VARCHAR, OrigObsDataID VARCHAR, ErrorRisk VARCHAR, Reference VARCHAR, "Comment" VARCHAR, StdValueStr VARCHAR);
CREATE TABLE taxonomy(SNo BIGINT, TRY_SpeciesID VARCHAR, TRY_SpeciesName VARCHAR, AccSpeciesID VARCHAR, TRY_AccSpeciesName VARCHAR, TRY_AccSpeciesNameScientific VARCHAR, BackboneDatabase VARCHAR, Genus VARCHAR, Family VARCHAR, NameUsedForFuzzyMatching VARCHAR, MatchedName VARCHAR, RecommendedScientificName VARCHAR, Reference VARCHAR, DiffGen VARCHAR, DiffSpec VARCHAR, SelectReason VARCHAR, AlternativeName VARCHAR, wikidata_id VARCHAR, rank_id VARCHAR, parent_id VARCHAR, ncbi_id VARCHAR, gbif_id VARCHAR, ott_id VARCHAR);
CREATE TABLE enpkg(raw_material VARCHAR, submitted_taxon VARCHAR, wd_taxon_id VARCHAR, organ VARCHAR, broad_organ VARCHAR, tissue VARCHAR, subsystem VARCHAR);
CREATE TABLE traits(TraitID VARCHAR, TraitName VARCHAR, TOP_ID VARCHAR);



