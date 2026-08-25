WITH as_director AS (
    SELECT c.nconst, AVG(r.average_rating) AS avg_rating_as_director, COUNT(*) AS titles_directed
    FROM {{ ref('bridge_title_crew') }} c
    JOIN {{ ref('fct_title_ratings') }} r ON c.tconst = r.tconst
    WHERE c.role = 'director'
    GROUP BY c.nconst
),
as_actor AS (
    SELECT c.nconst, AVG(r.average_rating) AS avg_rating_as_actor, COUNT(*) AS titles_acted
    FROM {{ ref('bridge_title_crew') }} c
    JOIN {{ ref('fct_title_ratings') }} r ON c.tconst = r.tconst
    WHERE c.role = 'actor'
    GROUP BY c.nconst
)

SELECT
    p.primary_name,
    ROUND(d.avg_rating_as_director, 2) AS avg_rating_as_director,
    ROUND(a.avg_rating_as_actor, 2) AS avg_rating_as_actor,
    ROUND(d.avg_rating_as_director - a.avg_rating_as_actor, 2) AS director_advantage,
    d.titles_directed,
    a.titles_acted
FROM as_director d
JOIN as_actor a ON d.nconst = a.nconst
JOIN {{ ref('dim_person') }} p ON d.nconst = p.nconst
WHERE d.titles_directed >= 3 AND a.titles_acted >= 3
ORDER BY ABS(d.avg_rating_as_director - a.avg_rating_as_actor) DESC
LIMIT 20