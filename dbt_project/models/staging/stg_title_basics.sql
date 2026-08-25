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
TRY_CAST(NULLIF(startYear, '\N') AS INTEGER) AS start_year,
TRY_CAST(NULLIF(endYear, '\N') AS INTEGER) AS end_year,
TRY_CAST(NULLIF(runtimeMinutes, '\N') AS INTEGER) AS runtime_minutes,
NULLIF(genres,'\N') AS genres
FROM {{source('imdb','title_basics')}}