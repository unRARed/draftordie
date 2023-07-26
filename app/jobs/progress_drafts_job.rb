class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    candidates = ViewDraftProgressionCandidate.all.
      where(is_selected: true).
      pluck(
        :draft_slug,
        :current_selection_id,
        :next_selection_id
      )
    return if candidates.empty?

    logger.info "Progressing drafts: #{candidates.map{|s| s[0]}}"
    # do this in one query for performance
    Selection.where(id: candidates.map{|s| s[1]}).
      update_all(ended_at: Time.current)

    # these need to be 1 by 1 so the hook fires
    # to broadcast the draft progression
    candidates.map{|s| s[2]}.each do |selection_id|
      Selection.find(selection_id).
        update(started_at: Time.current)
    end
  end
end
