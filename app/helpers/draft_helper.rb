module DraftHelper
  # converts a number of seconds into a
  # tuple of minutes and seconds
  def minutes_and_seconds(seconds)
    return [0, 0] unless seconds > 0
    [(seconds / 60).floor, (seconds % 60).floor]
  end

  def selection_class(draft, selection)
    classes = ["c-draft__board__slot"]
    if selection.position
      classes << "c-draft__board__slot--" +
        selection.position.downcase
    end
    if selection.is_selected?
      classes << "c-draft__board__slot--selected"
    end
    if draft.current_selection == selection
      classes << "c-draft__board__slot--current"
    end
    classes.join(" ")
  end

  def compute_text_size(user_count)
    case user_count
    when 15..20
      8
    when 11..14
      10
    when 7..10
      14
    else
      20
    end
  end
end
