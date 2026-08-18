SELECT nconst, primary_name, birth_year, death_year, primary_profession
FROM {{ ref('stg_name_basics') }}