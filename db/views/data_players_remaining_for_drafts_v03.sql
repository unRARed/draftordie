-- REMAINING PLAYERS FOR DRAFTS
--
-- For the select boxes on the bulk edit page and the draft board
--
select distinct on (d.id, pl.position, value_for_sort)
	pl.id,
	d.id as draft_id,
	CONCAT(
		pl.name, ' (', pl.position, ', ', pl.team, ')'
	) as player_data,
	CONCAT(
		pl.position, ' ', pl.name
	) as value_for_sort,
	(selected_players.draft_id is not null) as is_selected
from players pl
cross join drafts d
inner join rounds r on
	r.draft_id = d.id
inner join selections s on
	s.round_id = r.id
left outer join (
	select
		pl.id as selected_player_id,
		d.id as draft_id
	from players as pl
	inner join selections s on
		s.player_id = pl.id
	inner join rounds r on
		r.id = s.round_id
	inner join drafts d on
		d.id = r.draft_id
) as selected_players on
	pl.id = selected_players.selected_player_id and
	selected_players.draft_id = d.id
order by
	d.id,
  pl.position desc,
	value_for_sort
