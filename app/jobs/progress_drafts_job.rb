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
    Selection.transaction do
      Selection.where(id: candidates.map{|s| s[1]}).
        update_all(ended_at: Time.current)
      Selection.where(id: candidates.map{|s| s[2]}).
        update_all(started_at: Time.current)
    end
  end
end
