SELECT tconst,
unnest(string_split(genres,',')) AS genre
FROM {{ref('stg_title_basics')}}
WHERE genres IS NOT NULL
