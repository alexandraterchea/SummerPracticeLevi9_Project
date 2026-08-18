from __future__ import annotations

from datetime import datetime
from pathlib import Path

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

import duckdb
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq


PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"
RAW_DIR = PROJECT_DIR / "raw"
DBT_PROJECT_DIR = "/opt/airflow/dbt_project"
DB_PATH = f"{DBT_PROJECT_DIR}/dev.duckdb"

FILES = [
    "name.basics.tsv.gz",
    "title.akas.tsv.gz",
    "title.basics.tsv.gz",
    "title.crew.tsv.gz",
    "title.episode.tsv.gz",
    "title.principals.tsv.gz",
    "title.ratings.tsv.gz",
]

PARQUET_TO_TABLE = {
    "name.basics.parquet": "name_basics",
    "title.akas.parquet": "title_akas",
    "title.basics.parquet": "title_basics",
    "title.crew.parquet": "title_crew",
    "title.principals.parquet": "title_principals",
    "title.ratings.parquet": "title_ratings",
}


def extract_to_parquet():
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    for file in FILES:
        input_path = DATA_DIR / file
        output_path = RAW_DIR / file.replace(".tsv.gz", ".parquet")

        if output_path.exists():
            output_path.unlink()

        print(f"Reading {file}...", flush=True)

        if not input_path.exists():
            raise FileNotFoundError(f"Input file not found: {input_path}")

        writer = None

        try:
            for chunk_number, chunk in enumerate(
                pd.read_csv(
                        input_path,
                        sep="\t",
                        compression="gzip",
                        na_values="\\N",
                        chunksize=100_000,
                        dtype= "string",
                ),
                start=1,
            ):
                print(
                    f"{file}: processing chunk {chunk_number} "
                    f"({len(chunk)} rows)...",
                    flush=True,
                )

                table = pa.Table.from_pandas(
                    chunk,
                    preserve_index=False,
                )

                if writer is None:
                    writer = pq.ParquetWriter(
                        output_path,
                        table.schema,
                        compression="snappy",
                    )

                writer.write_table(table)

                print(
                    f"{file}: finished chunk {chunk_number}",
                    flush=True,
                )

        finally:
            if writer is not None:
                writer.close()

        print(f"Finished {file} -> {output_path}", flush=True)


def load_to_duckdb():
    con = duckdb.connect(DB_PATH)
    for parquet_file, table_name in PARQUET_TO_TABLE.items():
        parquet_path = RAW_DIR / parquet_file
        if not parquet_path.exists():
            raise FileNotFoundError(f"Parquet file not found: {parquet_path}")
        print(f"Loading {parquet_file} -> {table_name}...", flush=True)
        con.execute(
            f"CREATE OR REPLACE TABLE {table_name} AS "
            f"SELECT * FROM read_parquet('{parquet_path}')"
        )
        count = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f"Loaded {count} rows into {table_name}", flush=True)
    con.close()


def validate_load():
    con = duckdb.connect(DB_PATH)
    for table_name in PARQUET_TO_TABLE.values():
        count = con.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        if count == 0:
            raise ValueError(f"Table {table_name} is empty after load")
        print(f"{table_name}: {count} rows OK", flush=True)
    con.close()


default_args = {
    "owner": "imdb",
    "depends_on_past": False,
    "retries": 1,
}


with DAG(
    dag_id="imdb_ingestion",
    description="IMDb data ingestion pipeline",
    default_args=default_args,
    start_date=datetime(2026, 8, 1),
    schedule=None,
    catchup=False,
    max_active_tasks=1,
    tags=["imdb", "duckdb", "dbt"],
    doc_md="""
    ### IMDb pipeline
    1. **extract_to_parquet** — TSV.gz → Parquet in raw/
    2. **load_to_duckdb** — Parquet → DuckDB tables
    3. **validate_load** — fail fast if any table is empty
    4. **dbt_run** — staging → intermediate → marts
    5. **dbt_test** — schema + custom tests
    """,
) as dag:

    start = EmptyOperator(task_id="start")

    extract = PythonOperator(
        task_id="extract_to_parquet",
        python_callable=extract_to_parquet,
    )

    load = PythonOperator(
        task_id="load_to_duckdb",
        python_callable=load_to_duckdb,
    )

    validate = PythonOperator(
        task_id="validate_load",
        python_callable=validate_load,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt run --project-dir . --profiles-dir ."
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt test --project-dir . --profiles-dir ."
        ),
    )

    finish = EmptyOperator(task_id="finish")

    start >> extract >> load >> validate >> dbt_run >> dbt_test >> finish