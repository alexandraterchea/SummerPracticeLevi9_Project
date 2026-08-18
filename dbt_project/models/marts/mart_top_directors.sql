WITH director_titles AS ( 
    SELECT c.nconst, p.primary_name, r.average_rating, r.num_votes 
    FROM {{ref('bridge_title_crew')}} AS c
    JOIN {{ref('dim_person')}} AS p ON c.nconst = p.nconst
    JOIN {{ref('fct_title_ratings')}} AS r ON c.tconst = r.tconst
    WHERE c.role='director'
)
SELECT nconst, primary_name,
COUNT(*) AS title_count,
ROUND(AVG(average_rating),2) AS avg_rating,
SUM(num_votes) AS total_votes
FROM director_titles
GROUP BY nconst, primary_name   
HAVING COUNT(*) >= 5 AND SUM(num_votes) >= 1000
ORDER BY avg_rating DESC
LIMIT 10