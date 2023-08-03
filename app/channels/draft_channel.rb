class DraftChannel < ApplicationCable::Channel
  def subscribed
    puts params
    @draft = Draft.eager_load(:progression).
      where(slug: params[:slug]).first
    puts "SUBSCRIBED TO DraftChannel!"
    stream_for @draft
  end

  def receive(data)
    puts "RECEIVED DATA"
    payload = data["payload"]

    case data["command"]
    when "poll_current_selection"
      if payload["is_time_expired"]
        puts "TIME EXPIRED"
        advance_selection(data)
      end
    else
      puts "COMMAND NOT RECOGNIZED"
    end
  end

  def poll_current_selection(data)
    puts data
    @draft = Draft.eager_load(:progression).
      where(slug: data["slug"]).first
    result = @draft.current_selection.time_expired?
    puts "RESULT: #{result}"

    DraftChannel.broadcast_to(@draft, {
      command: "poll_current_selection",
      payload: {
        is_time_expired: @draft.current_selection.time_expired?
      }
    })
  end

  def advance_selection(data)
    puts "ADVANCING SELECTION"
    @draft = Draft.eager_load(:progression).
      where(slug: data["slug"]).first
    return unless @draft.progression.
      current_selection.time_expired?

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

