SELECT DISTINCT start_year AS year
FROM {{ ref('stg_title_basics') }}
WHERE start_year IS NOT NULL