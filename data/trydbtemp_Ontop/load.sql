COPY trydbAll FROM 'trydbtempontop/trydball.csv' (FORMAT 'csv', quote '"', delimiter ',', header 1);
COPY taxonomy FROM 'trydbtempontop/taxonomy.csv' (FORMAT 'csv', quote '"', delimiter ',', header 1);
COPY enpkg FROM 'trydbtempontop/enpkg.csv' (FORMAT 'csv', quote '"', delimiter ',', header 1);
COPY traits FROM 'trydbtempontop/traits.csv' (FORMAT 'csv', quote '"', delimiter ',', header 1);
