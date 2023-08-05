class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if args[0].present?
      draft = args[0][:draft]
      user = args[0][:user]
    end
    puts "arguments: #{args.to_s}"
    puts "ProgressDraftsJob running!"
    candidates = ViewDraftProgressionCandidate.all.
      where(is_selected: true)
    if !draft.nil?
      candidates = candidates.where(draft_slug: draft.slug)
    end
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

    attributes = { ended_at: Time.current }
    if !user.nil?
      attributes = attributes.merge({selecting_user: user})
    end
    # End all the prior "current" selections
    candidates.map{|s| s[1]}.each do |s|
      selection = Selection.find(s)
      Selection.find(s).update(attributes)
    end
  end
end
