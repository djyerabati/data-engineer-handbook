DROP TYPE IF EXISTS public.film_stats;

CREATE TYPE public.film_stats AS
(
	film text,
	votes integer,
	rating real,
	filmid text,
	film_year integer
);

-- DROP TYPE IF EXISTS public.quality_class;

CREATE TYPE public.quality_class AS ENUM
    ('star', 'good', 'average', 'bad');

-- DROP TABLE IF EXISTS public.actors;

CREATE TABLE actors (
actor TEXT,
actorid TEXT,
films film_stats[],
quality_class quality_class,
is_active BOOLEAN,
current_year INTEGER
)
;
