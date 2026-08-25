# IMDb Data Engineering Project

Mandatory requirements: An end-to-end data pipeline that ingests IMDb datasets into DuckDB, transforms them with dbt into a star schema and answers three analytical questions about movies, directors and genres.

Extra added:

## Prerequisites
- Docker + Docker Compose
- Python
- `dbt-duckdb` (for local dbt runs): `pip install dbt-duckdb`

## Dataset Setup

Download the following files from https://datasets.imdbws.com/ and place them in the `data/` folder:

- `name.basics.tsv.gz`
- `title.akas.tsv.gz`
- `title.basics.tsv.gz`
- `title.crew.tsv.gz`
- `title.principals.tsv.gz`
- `title.ratings.tsv.gz`

## Run the Pipeline

```bash
docker-compose up -d
```

Open http://localhost:8083, then trigger the `imdb_ingestion` DAG manually.

The DAG runs these steps in order:
1. `extract_to_parquet` — converts TSV.gz files to Parquet in `raw/`
2. `load_to_duckdb` — loads Parquet files into DuckDB tables
3. `validate_load` — fails fast if any table is empty
4. `dbt_run` — runs all staging, intermediate and mart models
5. `dbt_test` — runs all schema and custom tests

## Run dbt Locally

```bash
cd dbt_project
dbt run --profiles-dir .
dbt test --profiles-dir .
dbt docs generate && dbt docs serve
```

## Project Structure

```
dags/               Airflow DAG definition
dbt_project/
  models/
    staging/        One model per raw source (renaming, casting, null handling)
    intermediate/   Exploded/reshaped models before marts
    marts/          Final star schema tables and deliverable queries
  snapshots/        SCD Type 2 snapshots for dim_title and title_ratings
  tests/            Custom SQL data quality tests
raw/                Parquet files (git-ignored)
data/               Raw TSV.gz source files (git-ignored)
docs/               Project documentation
```

## Deliverable Questions

| Question | Model |
|---|---|
| Top 10 directors by average rating (5+ titles, 1000+ votes) | `mart_top_directors` |
| Average movie runtime by decade and correlation with rating | `mart_runtime_by_decade` |
| Genres with highest ratio of hidden gems vs overrated titles | `mart_genre_gems` |