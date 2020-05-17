with c_race as (
select
  race_key,
  race_day,
  place_code,
  case place_code
    when '1' then '札幌'
    when '2' then '函館'
    when '3' then '福島'
    when '4' then '新潟'
    when '5' then '東京'
    when '6' then '中山'
    when '7' then '中京'
    when '8' then '京都'
    when '9' then '阪神'
    when '10' then '小倉'
    else 'その他'
  end as place_name,
  right(race_key, 2) as race_number,
  replace(replace(replace(replace(races.race_name, 'Ｇ１', ''), 'Ｇ２', ''), 'Ｇ３', ''), '・', '') AS c_race_name,
  race_type,
  race_condition as race_condition_code,
  race_grade,
  case
    when race_condition = 'A1' then '新馬'
    when race_condition = 'A3' then '未勝利'
    when race_condition = '05' then '500万下・1勝クラス'
    when race_condition = '10' then '1000万下・2勝クラス'
    when race_condition = '16' then '1600万下・3勝クラス'
    when race_condition = 'OP' and race_grade = '1' then 'G1'
    when race_condition = 'OP' and race_grade = '2' then 'G2'
    when race_condition = 'OP' and race_grade = '3' then 'G3'
    when race_condition = 'OP' and race_grade in ('4', '5', '6') then 'OP'
    else 'その他'
  end as race_grade_type,
  track_type_code,
  case track_type_code
    when '1' then '芝'
    when '2' then 'ダート'
    else 'その他'
  end as track_type,
  distance,
  head_count,
  right_left as right_left_code,
  case right_left
    when '1' then '右回り'
    when '2' then '左回り'
    when '3' then '不明'
    when '9' then '障害'
    else 'その他'
  end as right_left_type,
  in_out as in_out_code,
  case in_out
    when '1' then '内回り'
    when '2' then '外回り'
    when '3' then '不明'
    when '9' then '障害'
    else 'その他'
  end as in_out_type
from
  races
),
c_horse as (
select
  *,
  lag(c_race_name, 1) over(partition by pedigree_register order by race_rank) as lag_c_race_name
from
  (
    select
      result.race_key,
      result.pedigree_register,
      horse.horse_name,
      result.date,
      result.rank,
      case when result.rank in ('01', '02', '03') then result.rank else '04~' end as c_rank,
      race.c_race_name,
      row_number() over(partition by result.pedigree_register order by date asc) as race_rank
    from
      (
        select
          race_key,
          pedigree_register,
          date,
          rank
        from
          results
      ) as result
      left join
      (
        select
          race_key,
          replace(replace(replace(replace(races.race_name, 'Ｇ１', ''), 'Ｇ２', ''), 'Ｇ３', ''), '・', '') AS c_race_name
        from
          races
      ) as race
        on result.race_key = race.race_key
      left join
      (
        select
          pedigree_register,
          horse_name
        from
          horses
      ) as horse
        on result.pedigree_register = horse.pedigree_register
  ) as tmp
)
select
  c_race_name,
  lag_c_race_name,
  max(case c_rank when '01' then rank_count else 0 end) as first_count,
  max(case c_rank when '02' then rank_count else 0 end) as second_count,
  max(case c_rank when '03' then rank_count else 0 end) as third_count,
  max(case c_rank when '04~' then rank_count else 0 end) as out_count
from
  (
  select
    c_race_name,
    lag_c_race_name,
    c_rank,
    count(*) as rank_count
  from
    (
      select
        c_race.*,
        c_horse.pedigree_register,
        c_horse.horse_name,
        c_horse.c_rank,
        c_horse.race_rank,
        c_horse.lag_c_race_name
      from
        c_race
        left join c_horse
          on c_race.race_key = c_horse.race_key
    ) as tmp1
  group by
    c_race_name, lag_c_race_name, c_rank
  ) as tmp2
group by
  c_race_name, lag_c_race_name