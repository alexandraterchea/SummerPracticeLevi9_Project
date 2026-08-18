SELECT tconst,genre
FROM {{ ref('stg_title_genres') }}
