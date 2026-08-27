import duckdb
import pathlib

raw = pathlib.Path(__file__).resolve().parent.parent / "raw"
db_path = pathlib.Path(__file__).resolve().parent.parent / "dbt_project" / "dev.duckdb"

tables = {
    "name.basics.parquet": "name_basics",
    "title.akas.parquet": "title_akas",
    "title.basics.parquet": "title_basics",
    "title.crew.parquet": "title_crew",
    "title.principals.parquet": "title_principals",
    "title.ratings.parquet": "title_ratings",
}

con = duckdb.connect(str(db_path))
for f, t in tables.items():
    p = raw / f
    print(f"Loading {t}...", flush=True)
    con.execute(f"CREATE OR REPLACE TABLE {t} AS SELECT * FROM read_parquet('{p}')")
    count = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
    print(f"{t}: {count} rows", flush=True)
con.close()
print("Done.")
