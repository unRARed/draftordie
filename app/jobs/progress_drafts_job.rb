class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "ProgressDraftsJob running!"
    candidates = ViewDraftProgressionCandidate.all.
      where(is_selected: true)
    if args[0].present?
      candidates = candidates.where(draft_slug: args[0][:slug])
    end
    candidates = candidates.
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
      selection = Selection.find(selection_id)
      puts "SELECTION: #{selection.inspect}"

      unless (selection = Selection.find(selection_id))
        # we just ended the last selection, so
        # we need to end the draft now
        selection.draft.update(ended_at: Time.current)
      end

      selection.update(started_at: Time.current)
    end
  end
end
