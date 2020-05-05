select
  *,
  first_count + second_count + third_count + out_count as total_count
from
  (
	select
	  c_race_name
	  ,horse_num
	  ,max(case rank when '01' then rank_count else 0 end) as first_count
	  ,max(case rank when '02' then rank_count else 0 end) as second_count
	  ,max(case rank when '03' then rank_count else 0 end) as third_count
	  ,max(case when rank not in ('01', '02', '03') then rank_count else 0 end) as out_count
	from
	  (
		select
		  c_race_name
		  ,horse_num
		  ,rank
		  ,count(*) as rank_count
		from
		  (
		    select
		      race_key
		      ,replace(replace(replace(replace(races.race_name, 'Ｇ１', ''), 'Ｇ２', ''), 'Ｇ３', ''), '・', '') AS c_race_name
		    from
		      races
		  ) as c_races
		  left join results
		    on c_races.race_key = results.race_key
		group by
		  c_race_name, horse_num, rank
	  ) as tmp
	group by
	  c_race_name, horse_num
  ) as tmp
order by
  c_race_name
