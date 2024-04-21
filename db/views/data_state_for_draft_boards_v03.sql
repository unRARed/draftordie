-- STATE FOR DRAFT BOARDS
--
-- All Drafts that are in progress and ready for their
-- next selection. Meaning:
--
-- A Draft:
--   - has been started
--   - is not currently paused
--   - has not ended, yet (ended_at IS NULL)
--
-- A Selection:
--   - exists WITHOUT the ended_at set OR is orphaned
--   - (meaning no selection exists that started / not ended)
--   - Orphans have next_selection ONLY
--
SELECT DISTINCT ON (drafts.id) drafts.id AS draft_id,
  drafts.slug AS draft_slug,
  current_selection.pick_number as current_pick_number,
  CURRENT_TIMESTAMP as now,
  (
    current_selection.started_at + (
      drafts.selection_seconds
    )::double precision * 'PT1S'::interval
  ) as current_selection_ends_at,
  (
    -- a player has been selected
    (current_selection.player_id IS NOT NULL) OR
    -- a "missing" player has been written in
    (
      current_selection.write_in_name IS NOT NULL AND
      current_selection.write_in_position IS NOT NULL
    -- time has run out
    ) OR
    (
      current_selection.started_at + (
        (drafts.selection_seconds)::double precision * 'PT1S'::interval
      )
    ) < CURRENT_TIMESTAMP
  ) AS is_selected,
  prior_selection.id AS prior_selection_id,
  current_selection.id AS current_selection_id,
  coalesce(orphan_selections.id, next_selection.id) AS next_selection_id
FROM drafts
  INNER JOIN rounds ON drafts.id = rounds.draft_id
  LEFT JOIN selections current_selection on
    current_selection.draft_id = drafts.id and
    current_selection.started_at IS NOT NULL and
    current_selection.ended_at IS NULL
  LEFT JOIN selections prior_selection on
    prior_selection.draft_id = drafts.id and
    prior_selection.pick_number IS NOT NULL and
    prior_selection.pick_number = current_selection.pick_number - 1
  LEFT JOIN selections next_selection on
    next_selection.draft_id = drafts.id and
    next_selection.pick_number IS NOT NULL and
    next_selection.pick_number = current_selection.pick_number + 1
  left join (
  	select open_selections.id, drafts.id as draft_id FROM drafts
	INNER JOIN rounds ON drafts.id = rounds.draft_id
	-- first selection that has not "ended"
	LEFT JOIN (
	  select * from selections
	  order by pick_number asc
	) as started_selections on
	  started_selections.draft_id = drafts.id and
	  started_selections.started_at IS not NULL and
	  started_selections.ended_at is null
	inner join selections as open_selections on
	  open_selections.draft_id = drafts.id and
	  open_selections.started_at IS NULL and
	  open_selections.ended_at is null
	where
	  -- Only drafts "currently in progress"
	  -- (been started, hasn't ended yet and not paused)
	  drafts.started_at IS NOT NULL and
	  drafts.ended_at IS null and
	  drafts.is_paused = false and
	  started_selections.id is null
	order by open_selections.pick_number
	limit 1
  ) as orphan_selections on
  	orphan_selections.draft_id = drafts.id
where
  -- Only drafts "currently in progress"...
  drafts.started_at IS NOT NULL and
  drafts.ended_at IS null and
  drafts.is_paused = false;
