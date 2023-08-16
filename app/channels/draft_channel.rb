class DraftChannel < ApplicationCable::Channel
  def subscribed
    @draft = Draft.eager_load(:progression).
      where(slug: params[:slug]).first
    puts "SUBSCRIBED TO DraftChannel!"
    stream_for @draft
  end

  def requested_selection_state(data)
    puts "REQUESTED SELECTION STATE"
    @draft = Draft.eager_load(:progression).
      where(slug: data["slug"]).first
    if @draft.is_ended?
      DraftChannel.broadcast_to(
        @draft, { command: "draft_ended", payload: {} }
      )
    end

    puts @draft.current_selection
    result = @draft.current_selection.time_expired?
    puts "RESULT: #{result}"

    DraftChannel.broadcast_to(@draft, {
      command: "selection_state",
      payload: {
        is_time_expired: @draft.current_selection.time_expired?
      }
    })
  end

  def requested_selection_advance(data)
    puts "ADVANCING SELECTION"
    @draft = Draft.eager_load(:progression).
      where(slug: data["slug"]).first
    return unless @draft.progression.
      current_selection.time_expired?

    next_selection = @draft.next_selection

    ProgressDraftsJob.perform_later(
      user: current_user, draft: @draft
    )

    DraftChannel.broadcast_to(@draft, {
      command: "reload",
      payload: { selection_id: @draft.current_selection.id }
    })
  end

  def requested_reload(data)
    return unless current_user

    DraftChannel.broadcast_to(@draft, {
      command: "reload", payload: {}
    })
  end
end
