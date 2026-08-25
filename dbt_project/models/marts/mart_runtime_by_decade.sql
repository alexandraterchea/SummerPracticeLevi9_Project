SELECT (CAST(start_year AS INTEGER) / 10) * 10 AS decade,
ROUND(AVG(runtime_minutes),2) AS avg_runtime_minutes,
ROUND(AVG(average_rating),2) AS avg_rating,
COUNT(*) AS title_count
FROM {{ ref('fct_title_ratings') }} 
WHERE title_type='movie' AND start_year IS NOT NULL AND runtime_minutes IS NOT NULL
AND average_rating IS NOT NULL
GROUP BY decade ORDER BY decade