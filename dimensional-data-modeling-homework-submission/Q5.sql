	 --------------incremental_SCD
	 create type scd_type as (
						quality_class quality_class,
	                   	is_active boolean,
                		start_date INTEGER,
                		end_date INTEGER
)
;
with last_year_scd as (
select *
from actors_history_scd
where end_date = 1974
)
,historical_scd as (
select *
from actors_history_scd
where end_date < 1974
)
,this_year_data as (
		select * from actors where current_year = 1975		
)
,unchanged_records as (
select ty.actor
,ty.quality_class
,ty.is_active
,ly.start_date
,ty.current_year as end_year
from this_year_data ty
join last_year_scd ly on ly.actor = ty.actor
where ty.quality_class = ly.quality_class
and ty.is_active = ly.is_active 
)
 ,changed_records AS (
        SELECT
                ty.actor,
                UNNEST(ARRAY[
                    ROW(
                        ly.quality_class,
                        ly.is_active,
                        ly.start_date,
                        ly.end_date

                        )::scd_type,
                    ROW(
                        ty.quality_class,
                        ty.is_active,
                        ty.current_year,
                        ty.current_year
                        )::scd_type
                ]) as records
        FROM this_year_data ty
        LEFT JOIN last_year_scd ly
        ON ly.actor = ty.actor
         WHERE (ty.quality_class <> ly.quality_class
          OR ty.is_active <> ly.is_active)
     )
         ,unnested_changed_records AS (

         SELECT actor,
                (records::scd_type).quality_class,
                (records::scd_type).is_active,
                (records::scd_type).start_date,
                (records::scd_type).end_date
                FROM changed_records
         )
         
        , new_records as (
          SELECT
           ty.actor,
               ty.quality_class,
               ty.is_active,
               ty.current_year AS start_date,
               ty.current_year AS end_date
         FROM this_year_data ty
         LEFT JOIN last_year_scd ly
             on ty.actor =ly.actor
         where ly.actor IS NULL

         )
         SELECT *
                  FROM historical_scd

                  UNION ALL

                  SELECT *
                  FROM unchanged_records

                  UNION ALL

                  SELECT *
                  FROM unnested_changed_records

                  UNION ALL

                  SELECT *
                  FROM new_records