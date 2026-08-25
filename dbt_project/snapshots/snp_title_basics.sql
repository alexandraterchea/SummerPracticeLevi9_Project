{% snapshot snp_title_basics %}

{{
    config(
        target_schema='snapshots',
        unique_key='tconst',
        strategy='check',
        check_cols=['primary_title', 'genres', 'runtime_minutes']
    )
}}

SELECT
    tconst,
    primary_title,
    original_title,
    title_type,
    genres,
    runtime_minutes,
    start_year,
    end_year
FROM {{ ref('stg_title_basics') }}

{% endsnapshot %}