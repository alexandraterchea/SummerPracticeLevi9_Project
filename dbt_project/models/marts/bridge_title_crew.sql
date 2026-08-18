SELECT tconst, nconst, role 
FROM {{ ref('int_crew_exploded') }}
UNION ALL
SELECT tconst, nconst, category AS role
FROM {{ ref('stg_title_principals') }}
WHERE category NOT IN ('director', 'writer') 