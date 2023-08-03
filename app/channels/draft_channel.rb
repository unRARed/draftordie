class DraftChannel < ApplicationCable::Channel
  def subscribed
    puts params
    @draft = Draft.eager_load(:progression).
      where(slug: params[:slug]).first
    puts "SUBSCRIBED TO DraftChannel!"
    stream_for "show_#{@draft.slug}", data: { slug: @draft.slug }
  end

  def receive(data)
    puts data
  end

  def is_between_selections(data)
    @draft = Draft.eager_load(:progression).
      where(slug: data["slug"]).first
    result = @draft.current_selection.time_expired?
    # return "show_#{data["slug"]}", {
    # })
    ActionCable.server.broadcast(
      "show_#{@draft.slug}", {
        context: "is_between_selections",
        payload: { value: @draft.current_selection.time_expired? }
      }
    )
  end

  def advance_selection(data)
    puts "ADVANCING SELECTION"
    @draft = Draft.eager_load(:progression).
      where(slug: data["slug"]).first
    return unless @draft.progression.
      current_selection.time_expired?

    next_selection = @draft.progression.next_selection
    ProgressDraftsJob.perform_later(slug: @draft.slug)
    # @draft.progression.current_selection.
    #   update(ended_at: Time.current)
    # next_selection.update(started_at: Time.current)
  end

  def selected
    @draft = Draft.eager_load(:progression).
      where(slug: params[:slug]).first
  end
end

