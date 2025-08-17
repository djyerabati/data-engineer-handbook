	--- scd generator for actors 
	WITH streak_started AS (
    SELECT actor,
           current_year,
           quality_class,
           is_active,
           LAG(quality_class, 1) OVER
               (PARTITION BY actor ORDER BY current_year) <> quality_class
               OR LAG(quality_class, 1) OVER
               (PARTITION BY actor ORDER BY current_year) IS null
               or LAG(is_active, 1) OVER
               (PARTITION BY actor ORDER BY current_year) <> is_active
               OR LAG(is_active, 1) OVER
               (PARTITION BY actor ORDER BY current_year) IS null
               AS did_change
    from actors
)
,     streak_identified AS (
         SELECT
            actor,
                quality_class,
                is_active,
                current_year,
            SUM(CASE WHEN did_change THEN 1 ELSE 0 END)
                OVER (PARTITION BY actor ORDER BY current_year) as streak_identifier
         FROM streak_started
     ),
     aggregated AS (
         SELECT
            actor,
            quality_class,
            is_active,
            streak_identifier,
            MIN(current_year) AS start_date,
            MAX(current_year) AS end_date
         FROM streak_identified
         GROUP BY 1,2,3,4
     )
	insert into actors_history_scd
     SELECT actor, quality_class,is_active, start_date, end_date
     FROM aggregated
     order by actor
	 ;
