SELECT tconst
FROM {{ ref('dim_title') }}
WHERE start_year > YEAR(CURRENT_DATE)