SELECT nconst,
TRIM(unnest(string_split(known_for_titles, ','))) AS tconst
FROM {{ ref('stg_name_basics') }}
WHERE known_for_titles IS NOT NULL