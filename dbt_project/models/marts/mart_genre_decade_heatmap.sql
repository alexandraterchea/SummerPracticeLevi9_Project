SELECT
    g.genre,
    (r.start_year / 10) * 10 AS decade,
    ROUND(AVG(r.average_rating), 2) AS avg_rating,
    COUNT(*) AS title_count
FROM {{ ref('bridge_title_genres') }} g
JOIN {{ ref('fct_title_ratings') }} r ON g.tconst = r.tconst
WHERE r.start_year IS NOT NULL
  AND r.start_year >= 1950
  AND g.genre IS NOT NULL
GROUP BY g.genre, decade
HAVING COUNT(*) >= 20
ORDER BY g.genre, decade