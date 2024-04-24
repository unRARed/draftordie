class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    logger.info "ProgressDraftsJob (performing)"
    if args[0].present?
      logger.info "With arguments: #{args[0].to_s}"
      draft = args[0][:draft]
      user = args[0][:user]
    end
    draft_board_state = DataStateForDraftBoard.all
    if !draft.nil?
      draft_board_state = draft_board_state.
        where(draft_slug: draft.slug)
    end
    return if draft_board_state.empty?

    active_progressions =
      draft_board_state.map{|state| Progression.new(state) }

    # Split candidates into two arrays
    # 1. those with a current selection
    # 2. those with ONLY a next selection (orphans)
    orphans = active_progressions.select(&:orphaned?)
    active_progressions =
      (active_progressions - orphans) if !orphans.empty?
    # candidates are those with a current
    # selection that IS also selected
    candidates = active_progressions.select(&:ready_to_advance?)

    active_progressions.each do |p|
      logger.info "Progression:"
      logger.info p
      next unless p.current_selection_id

      logger.info "Current Selection:"
      logger.info Selection.find(p.current_selection_id).
        attributes.to_json
      #if orphans.include? p
      #current_selection.poll!
    end


#     # Bail if there's nothing to do...
#     if (
#       candidates.empty? &&
#      orphans.empty? && active_progressions.empty?
#     )
#       return
#     end

    progress_orphans(orphans) unless orphans.empty?

    unless candidates.empty?
      progress_candidates(candidates, user || nil)
    end

    refresh_clients(candidates + orphans)
  end

  def progress_orphans(progressions)
    logger.info "Progressing Orphans..."
    draft_slugs = progressions.map(&:draft_slug)
    logger.info "Progressing #{draft_slugs.length} Orphans."
    logger.info "Fixing orphans: #{draft_slugs}"
    Selection.where(
      id: progressions.map(&:next_selection_id).compact
    ).update_all(started_at: Time.current)
  end

  def progress_candidates(candidates, user = nil)
    logger.info "Progressing #{candidates.length} Candidates."
    # Start the clock for All the next selections
    Selection.where(
      id: (candidates.map(&:next_selection_id).compact)
    ).update_all(started_at: Time.current)

    attributes = { ended_at: Time.current }
    if !user.nil?
      attributes = attributes.merge({selecting_user: user})
    end

    # End all the "current" selections
    candidates.each do |p|
      current_selection = Selection.find(p.current_selection_id)
      current_selection.assign_attributes(attributes)
      current_selection.save(validate: false)

      # End the draft if this was the last selection
      if p.next_selection_id.nil?
        draft = Draft.find_by(slug: p.draft_slug)
        draft.update_columns(ended_at: Time.current)
      end
    end
  end

  # Informs all connected clients that something has changed
  # and a page refresh is requested.
  def refresh_clients(progressions)
    draft_slugs = progressions.map(&:draft_slug)
    logger.info "Refreshing clients for drafts: #{draft_slugs}"
    draft_slugs.each do |slug|
      draft_to_advance = Draft.find_by(slug: slug)
      DraftChannel.broadcast_to(draft_to_advance, {
        command: "refresh", payload: {}
      })
    end
  end
end
