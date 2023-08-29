class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if args[0].present?
      draft = args[0][:draft]
      user = args[0][:user]
    end
    puts "arguments: #{args.to_s}"
    puts "ProgressDraftsJob running!"
    open_progressions = DataStateForDraftBoard.all
    if !draft.nil?
      open_progressions = open_progressions.
        where(draft_slug: draft.slug)
    end
    return if open_progressions.empty?

    open_progressions = open_progressions.
      pluck(
        :draft_slug,
        :current_selection_id,
        :next_selection_id,
        :is_selected
      )

    # Split candidates into two arrays
    # 1. those with a current selection
    # 2. those with ONLY a next selection (orphans)
    orphans = open_progressions.
      select{|c| c[1].nil? && !c[2].nil? }
    open_progressions =
      (open_progressions - orphans) if !orphans.empty?
    # candidates are those with a current
    # selection that IS also selected
    candidates = open_progressions.
      select{|c| !c[1].nil? && c[3] }

    return if candidates.empty? && orphans.empty?

    progress_orphans(orphans) unless orphans.empty?

    unless candidates.empty?
      progress_candidates(candidates, user || nil)
    end

    inform_clients(candidates + orphans)
  end

  def progress_orphans(data)
    draft_slugs = data.map{|s| s[0]}
    logger.info "Fixing orphans: #{draft_slugs}"
    Selection.where(id: data.map{|s| s[2]}).
      update_all(started_at: Time.current)
  end

  def progress_candidates(candidates, user = nil)
    # Start the clock for All the next selections
    Selection.where(id: candidates.map{|s| s[2]}).
      update_all(started_at: Time.current)

    attributes = { ended_at: Time.current }
    if !user.nil?
      attributes = attributes.merge({selecting_user: user})
    end

    # End all the "current" selections
    candidates.each do |candidate|
      current_selection = Selection.find(candidate[1])
      current_selection.assign_attributes(attributes)
      current_selection.save(validate: false)

      # End the draft if this was the last selection
      if candidate[2].nil?
        draft = Draft.find_by(slug: candidate[0])
        draft.update_columns(ended_at: Time.current)
      end
    end
  end

  def inform_clients(data)
    draft_slugs = data.map{|s| s[0]}
    logger.info "Progressing drafts: #{draft_slugs}"
    draft_slugs.each do |slug|
      draft_to_advance = Draft.find_by(slug: slug)
      DraftChannel.broadcast_to(draft_to_advance, {
        command: "refresh", payload: {}
      })
    end
  end
end
