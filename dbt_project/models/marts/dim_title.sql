SELECT tconst, title_type, primary_title, original_title, is_adult, start_year, end_year, runtime_minutes
FROM {{ ref('stg_title_basics') }}