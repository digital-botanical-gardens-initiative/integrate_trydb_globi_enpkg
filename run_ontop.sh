#./ontop bootstrap -m data/Ontop_input_db/integrateX.obda -p data/Ontop_input_db/duckdb.properties -t data/Ontop_input_db/integrateX.owl -b http://example.org #For making ontology 'owl' and mapping 'obda' files 
#robot convert --input data/Ontop_input_db/integrateX.obda --format ttl --output data/Ontop_input_db/integrateX.ttl #Either use robot for converting owl file to ttl or use protege in Ontop-protege bundle
./ontop validate -l data/Ontop_input_db/lenses.json -p data/Ontop_input_db/duckdb.properties -m data/Ontop_input_db/integrateX.obda -t data/Ontop_input_db/integrateX.ttl #Validate all files
./ontop endpoint --ontology=data/Ontop_input_db/integrateX.ttl --mapping=data/Ontop_input_db/integrateX.obda --lenses=data/Ontop_input_db/lenses.json --properties=data/Ontop_input_db/duckdb.properties --enable-annotations #For creating SPARQL endpoint

