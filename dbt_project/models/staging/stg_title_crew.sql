SELECT tconst,
NULLIF(directors,'\N') AS directors,
NULLIF(writers,'\N') AS writers
FROM {{source('imdb','title_crew')}}