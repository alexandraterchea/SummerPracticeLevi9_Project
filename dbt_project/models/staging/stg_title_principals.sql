SELECT tconst,
ordering,
nconst,
category,
NULLIF(job,'\N') AS job,
NULLIF(characters,'\N') AS characters
FROM {{source('imdb','title_principals')}}