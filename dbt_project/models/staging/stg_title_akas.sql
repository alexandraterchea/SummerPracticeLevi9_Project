SELECT titleId AS title_id,
ordering,
title,
NULLIF(region, '\N') AS region,
NULLIF(language,'\N') AS language,
NULLIF(types,'\N') AS types,
NULLIF(attributes,'\N') AS attributes,
NULLIF(isOriginalTitle,'\N')::INTEGER AS is_original_title
FROM {{source('imdb','title_akas')}}