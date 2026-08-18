WITH labeled AS (
    SELECT g.genre, r.tconst, 
    CASE 
        WHEN r.average_rating >= 7.5 AND r.num_votes<1000 THEN 'hidden_gem'
        WHEN r.average_rating < 5.0 AND r.num_votes >= 10000 THEN 'overrated'
    END AS label
    FROM {{ ref('bridge_title_genres') }} AS g
    JOIN {{ ref('fct_title_ratings') }} AS r ON g.tconst = r.tconst
    
)

SELECT genre, COUNT(CASE WHEN label='hidden_gem' THEN 1 END) AS hidden_gems,
COUNT(CASE WHEN label='overrated' THEN 1 END) AS overrated,
COUNT(*) AS total_titles,
ROUND(COUNT(CASE WHEN label='hidden_gem' THEN 1 END)*100.0/COUNT(*),2) AS hidden_gem_pct
FROM labeled
WHERE genre IS NOT NULL
GROUP BY genre
ORDER BY hidden_gem_pct DESC