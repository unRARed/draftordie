-- REMAINING PLAYERS FOR DRAFTS
--
-- For the select boxes on the bulk edit page and the draft board
--
SELECT DISTINCT ON (
	d.id, pl.position, value_for_sort
)
	pl.id,
  d.id AS draft_id,
	CONCAT(
		pl.name,
    ' (', pl.position, ', ', pl.team, ')'
	) AS player_data,
	CONCAT(
		pl.position, ' ', pl.name
	) AS value_for_sort,
	(selected_players.draft_id IS NOT NULL) AS is_selected
FROM drafts d
INNER JOIN player_pools pp ON
  pp.id = d.player_pool_id
INNER JOIN players pl ON
  pl.player_pool_id = pp.id
INNER JOIN rounds r ON
	r.draft_id = d.id
INNER JOIN selections s ON
	s.round_id = r.id
LEFT OUTER JOIN (
	select
		pl.id AS selected_player_id,
		d.id AS draft_id
	FROM players AS pl
	INNER JOIN selections s ON
		s.player_id = pl.id
	INNER JOIN rounds r ON
		r.id = s.round_id
	INNER JOIN drafts d ON
		d.id = r.draft_id
  INNER JOIN player_pools pp ON
    pp.id = d.player_pool_id
) AS selected_players ON
	pl.id = selected_players.selected_player_id AND
	selected_players.draft_id = d.id
ORDER BY d.id,
  pl.position DESC,
	value_for_sort
