SELECT tconst,
NULLIF(averageRating, '\N')::DOUBLE AS average_rating,
NULLIF(numVotes,'\N')::INTEGER AS num_votes
FROM {{source('imdb','title_ratings')}}