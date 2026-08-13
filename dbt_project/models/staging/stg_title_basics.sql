SELECT
tconst,
titleType AS title_type,
primaryTitle AS primary_title,
originalTitle AS original_title,
CASE
    WHEN isAdult='1' THEN TRUE
    WHEN isAdult='0' THEN FALSE
    ELSE NULL
END AS is_adult,
NULLIF(startYear, '\N')::INTEGER AS start_year,
NULLIF(endYear,'\N')::INTEGER AS end_year,
NULLIF(runtimeMinutes,'\N')::INTEGER AS runtime_minutes,
NULLIF(genres,'\N') AS genres
FROM {{source('imdb','title_basics')}}