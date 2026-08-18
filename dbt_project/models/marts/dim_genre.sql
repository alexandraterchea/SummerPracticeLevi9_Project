SELECT DISTINCT genre
FROM {{ ref('stg_title_genres') }}
WHERE genre IS NOT NULL 
