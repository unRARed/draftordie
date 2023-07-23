-- DRAFT PROGRESSION CANDIDATES
--
-- All Drafts that are ready for their next
-- selection. Meaning:
--
-- The Draft:
--   - has been started
--   - is not currently paused
-- A Selection:
--   - exists WITHOUT the ended_at set
-- NO Selection:
--   - exists with BOTH started_at and ended_at set
SELECT DISTINCT ON (drafts.id) drafts.id AS draft_id,
  drafts.slug AS draft_slug,
  current_selection.pick_number as current_pick_number,
  -- localtimestamp as now,
  -- (current_selection.started_at + (drafts.selection_seconds)::double precision * 'PT1S'::interval) as current_pick_ends,
  (current_selection.started_at + 
    ((drafts.selection_seconds)::double precision * 'PT1S'::interval)
  ) < localtimestamp AS is_selected,
  prior_selection.id AS prior_selection_id,
  current_selection.id AS current_selection_id,
  next_selection.id AS next_selection_id
 FROM drafts
   INNER JOIN rounds ON drafts.id = rounds.draft_id
   INNER JOIN selections current_selection on
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
WHERE drafts.started_at IS NOT NULL and
	drafts.is_paused = false;
