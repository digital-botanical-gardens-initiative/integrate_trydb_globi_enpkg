COPY trydbAll FROM 'trydbAll_datatype_enpkg.tsv' (FORMAT 'csv', quote '', delimiter '\t', header 1);
COPY taxonomy FROM 'taxonomy_enpkg.tsv' (FORMAT 'csv', quote '', delimiter '\t', header 1);
COPY enpkg FROM 'enpkg.csv' (FORMAT 'csv', quote '"', delimiter ',', header 1);
COPY traits FROM 'traits.csv' (FORMAT 'csv', quote '"', delimiter ',', header 1);
COPY interactions FROM 'intxn_enpkg.tsv' (FORMAT 'csv', delimiter '\t', quote '', header 1);
