import duckdb

con=duckdb.connect()

con.sql("""
SELECT * 
FROM read_csv('data/title.ratings.tsv.gz', delim='\t',header=true)
LIMIT 10
        """).show()