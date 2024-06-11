from pandas import DataFrame
from rdflib.plugins.sparql.processor import SPARQLResult
from rdflib import Graph

### the function below is taken from "https://github.com/RDFLib/rdflib/issues/1179"######
def sparql_results_to_df(results: SPARQLResult) -> DataFrame:
    """
    Export results from an rdflib SPARQL query into a `pandas.DataFrame`,
    using Python types. See https://github.com/RDFLib/rdflib/issues/1179.
    """
    return DataFrame(
        data=([None if x is None else x.toPython() for x in row] for row in results),
        columns=[str(x) for x in results.vars],
    )
##########################################################################################

# Create graph
g = Graph()
g.parse("data/duckdb_materialized_triples1.rdf")

# Sample queries
q =  """PREFIX : <http://example.org/trydb_kg/>
        PREFIX wd: <http://www.wikidata.org/entity/>
        SELECT * WHERE {
            ?t :SpeciesName ?SpeciesName .
            ?t :AccSpeciesName ?AccSpeciesName . 
            ?t   :hasWdID ?wikidata_id .
            } LIMIT 100"""

q1 = """PREFIX : <http://example.org/trydb_kg/>
        PREFIX wd: <http://www.wikidata.org/entity/>
        SELECT DISTINCT ?targetWD WHERE {
            ?t :SpeciesName ?SpeciesName .
            ?t :AccSpeciesName ?AccSpeciesName . 
            ?t   :hasWdID ?wikidata_id .
            ?wikidata_id :interactsWith ?targetWD . 
            VALUES ?wikidata_id { <http://www.wikidata.org/entity/Q713794> }
        }"""

q2 = """PREFIX : <http://example.org/trydb_kg/>
        PREFIX wd: <http://www.wikidata.org/entity/>
        SELECT * WHERE {
            ?t :SpeciesName ?SpeciesName .
            ?t :AccSpeciesName ?AccSpeciesName . 
            ?t   :hasWdID ?wikidata_id .
            ?wikidata_id :interactsWith ?targetWD . 
            VALUES ?wikidata_id { <http://www.wikidata.org/entity/Q713794> }
            ?wikidata_id :raw_material ?raw_material . 
            ?wikidata_id :organ ?organ . 
            ?wikidata_id :subsystem ?subsystem .
        }"""
q3 = """PREFIX : <http://example.org/trydb_kg/>
        PREFIX wd: <http://www.wikidata.org/entity/>
        SELECT DISTINCT * WHERE {
            ?t :SpeciesName ?SpeciesName .
            ?t :AccSpeciesName ?AccSpeciesName . 
            ?t   :hasWdID ?wikidata_id . 
            VALUES ?wikidata_id { <http://www.wikidata.org/entity/Q713794> }
            ?wikidata_id :raw_material ?raw_material . 
            ?wikidata_id :organ ?organ .
            ?wikidata_id :subsystem ?subsystem .
        }"""
q4 = """PREFIX : <http://example.org/trydb_kg/>
        PREFIX wd: <http://www.wikidata.org/entity/>
        SELECT * WHERE {\n ?t :SpeciesName ?SpeciesName .
        ?t :AccSpeciesName ?AccSpeciesName . 
        ?t   :hasWdID ?wikidata_id .
        ?wikidata_id :interactsWith ?targetWD . 
        VALUES ?wikidata_id { <http://www.wikidata.org/entity/Q713794> }
        ?wikidata_id :hasIntxnId ?intxnID .
        }"""


# Run query, save in dataframe
s = g.query(q)
for row in s:
    print(f"{row.TRY_SpeciesName} has {row.wikidata_id} and alternately names {row.AccSpeciesName}")
s1 = sparql_results_to_df(s)
print(s1)


