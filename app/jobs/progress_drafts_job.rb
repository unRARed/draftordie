class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "ProgressDraftsJob running!"
    candidates = ViewDraftProgressionCandidate.all.
      where(is_selected: true)
    return if candidates.empty?

    candidates = candidates.
      pluck(
        :draft_slug,
        :current_selection_id,
        :next_selection_id
      )

    logger.info "Progressing drafts: #{candidates.map{|s| s[0]}}"

    # Start the clock for All the next selections
    Selection.where(id: candidates.map{|s| s[2]}).
      update_all(started_at: Time.current)

    # End all the prior "current" selections
    candidates.map{|s| s[1]}.each do |s|
      selection = Selection.find(s)
      Selection.find(s).update(ended_at: Time.current)
    end
  end
end
