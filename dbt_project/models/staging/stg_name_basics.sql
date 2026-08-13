SELECT nconst,
primaryName AS primary_name,
NULLIF(birthYear,'\N')::INTEGER AS birth_year,
NULLIF(deathYear,'\N')::INTEGER AS death_year,
NULLIF(primaryProfession,'\N')AS primary_profession,
NULLIF(knownForTitles,'\N') AS known_for_titles
FROM {{source('imdb','name_basics')}}