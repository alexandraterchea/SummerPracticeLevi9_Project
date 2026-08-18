{% snapshot snp_title_ratings %}

{{
    config(
        target_schema='snapshots',
        unique_key='tconst',
        strategy='check',
        check_cols=['average_rating', 'num_votes']
    )
}}

SELECT
    tconst,
    average_rating,
    num_votes
FROM {{ ref('stg_title_ratings') }}

{% endsnapshot %}