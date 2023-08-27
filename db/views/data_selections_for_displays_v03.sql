-- FOR PREVENTING N+1 QUERIES ON THE
-- DRAFT BOARD AND BULK EDIT PAGES
--
select distinct on (d.id, s.pick_number)
  s.id as selection_id,
  d.id as draft_id,
  r.number as round_number,
  s.pick_number,
  s.write_in_team,
  s.write_in_position,
  s.write_in_name,
  p.context_value as team_name,
  s.player_id,
  case
    when pl.name is not null and pl.name <> ''
    then CONCAT(
      '(',
      pl.position,
      ', ',
      pl.team,
      ') ',
      pl.name
    )
    when s.write_in_name is not null and s.write_in_name <> ''
    then CONCAT(
      '(',
      s.write_in_position,
      ', ',
      s.write_in_team,
      ') ',
      s.write_in_name
    )
    else
    NULL
  end as player_data
from drafts d
inner join rounds r on
  r.draft_id = d.id
inner join selections s on
  s.round_id = r.id
inner join pairings p on
  p.pairable_id = d.id and
  p.pairable_type = 'Draft' and
  p.context = 'Draft Team Name' and
  p.user_id = s.user_id
left outer join players pl on
  pl.id = s.player_id
order by d.id, s.pick_number, r.number
