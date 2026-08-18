WITH directors AS (
    SELECT tconst,
    TRIM(unnest(string_split(directors, ','))) AS nconst, 
    'director' AS role
    FROM {{ ref('stg_title_crew') }} 
    WHERE directors IS NOT NULL
),

writers AS (
    SELECT tconst,
    TRIM(unnest(string_split(writers, ','))) AS nconst, 
    'writer' AS role
    FROM {{ ref('stg_title_crew') }} 
    WHERE writers IS NOT NULL
)

SELECT * FROM directors
UNION ALL
SELECT * FROM writers