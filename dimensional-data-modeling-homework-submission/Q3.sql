	---DDL for actors_history_scd
	create table actors_history_scd(
		actor TEXT,
		quality_class quality_class,
		is_active BOOLEAN,
		start_date INTEGER,
		end_date INTEGER,
		primary key (actor,start_date)
	);
	