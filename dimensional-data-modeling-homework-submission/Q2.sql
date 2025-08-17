WITH last_year AS (

	    SELECT * FROM actors

	    WHERE current_year = 1969

	)

	, this_year AS (

	 select actor

	,actorid

	,array_agg(ROW(film,votes,rating,filmid,year)::film_stats) as films

	,(case when avg(rating) > 8 then 'star'

		  when avg(rating)  > 7 and avg(rating) <= 8 then 'good'

		  when avg(rating) > 6 and avg(rating) <=7 then 'average'

		  when avg(rating) <= 6 then 'bad'

		  end)::quality_class as quality_class

	  from actor_films 

	  where 1=1

	  and year = 1970

	group by 1,2
)

	insert into actors

	select 

	coalesce(ly.actor,ty.actor) as actor

	,coalesce(ly.actorid,ty.actorid) as actorid

	,coalesce(ly.films,array[]::film_stats[]) || ty.films as films

	,coalesce(ty.quality_class,ly.quality_class) as quality_class

	,ty.actorid is not null as is_active

	,1970 as current_year

	from last_year ly

	full outer join this_year ty on ly.actorid = ty.actorid
	
	;
