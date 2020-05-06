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
where
  race_name like '%有馬記念%'
