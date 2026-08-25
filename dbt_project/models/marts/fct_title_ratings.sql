SELECT r.tconst,
r.average_rating,
r.num_votes,
t.title_type,
t.primary_title,
t.start_year,
t.runtime_minutes
FROM {{ ref('stg_title_ratings') }} AS r
LEFT JOIN {{ ref('dim_title') }} AS t
ON r.tconst = t.tconst