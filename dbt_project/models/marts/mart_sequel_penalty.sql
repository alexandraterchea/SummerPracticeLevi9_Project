WITH classified AS (
    SELECT
        t.tconst,
        t.primary_title,
        r.average_rating,
        r.num_votes,
        CASE
            WHEN t.primary_title LIKE '% II'   OR t.primary_title LIKE '% III'
              OR t.primary_title LIKE '% IV'    OR t.primary_title LIKE '% V'
              OR t.primary_title LIKE '% 2'     OR t.primary_title LIKE '% 3'
              OR t.primary_title LIKE '% 4'     OR t.primary_title LIKE '% 5'
              OR t.primary_title LIKE '%: Part 2' OR t.primary_title LIKE '%: Part II'
            THEN 'sequel'
            ELSE 'original'
        END AS film_type
    FROM {{ ref('dim_title') }} t
    JOIN {{ ref('fct_title_ratings') }} r ON t.tconst = r.tconst
    WHERE t.title_type = 'movie'
      AND r.num_votes >= 1000
)

SELECT
    film_type,
    COUNT(*) AS title_count,
    ROUND(AVG(average_rating), 2) AS avg_rating,
    ROUND(AVG(num_votes), 0) AS avg_votes
FROM classified
GROUP BY film_type