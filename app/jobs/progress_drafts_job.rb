class ProgressDraftsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if args[0].present?
      draft = args[0][:draft]
      user = args[0][:user]
    end
    puts "arguments: #{args.to_s}"
    puts "ProgressDraftsJob running!"
    candidates = DataStateForDraftBoard.all.
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

    draft_slugs = candidates.map{|s| s[0]}
    logger.info "Progressing drafts: #{draft_slugs}"

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
    draft_slugs.each do |slug|
      draft_to_advance = Draft.find_by(slug: slug)
      DraftChannel.broadcast_to(draft_to_advance, {
        command: "refresh", payload: {}
      })
    end
  end
end
