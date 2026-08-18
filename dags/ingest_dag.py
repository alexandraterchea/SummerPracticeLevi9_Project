from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

from pathlib import Path
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from datetime import datetime


PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_DIR / "data"
RAW_DIR = PROJECT_DIR / "raw"

FILES = [
    "name.basics.tsv.gz",
    "title.akas.tsv.gz",
    "title.basics.tsv.gz",
    "title.crew.tsv.gz",
    "title.episode.tsv.gz",
    "title.principals.tsv.gz",
    "title.ratings.tsv.gz",
]


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
    tags=["imdb", "duckdb", "dbt"],
) as dag:

    start = EmptyOperator(
        task_id="start",
    )

    extract = PythonOperator(
        task_id="extract_to_parquet",
        python_callable=extract_to_parquet,
    )

    finish = EmptyOperator(
        task_id="finish",
    )

    start >> extract >> finish