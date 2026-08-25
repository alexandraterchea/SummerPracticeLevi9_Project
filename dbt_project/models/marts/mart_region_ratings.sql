SELECT
    a.region,
    COUNT(DISTINCT a.title_id) AS title_count,
    ROUND(AVG(r.average_rating), 2) AS avg_rating,
    SUM(r.num_votes) AS total_votes
FROM {{ ref('stg_title_akas') }} a
JOIN {{ ref('fct_title_ratings') }} r ON a.title_id = r.tconst
WHERE a.region IS NOT NULL
  AND r.average_rating IS NOT NULL
GROUP BY a.region
HAVING COUNT(DISTINCT a.title_id) >= 100
ORDER BY avg_rating DESC
LIMIT 20