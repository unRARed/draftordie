module DraftHelper
  # converts a number of seconds into a
  # tuple of minutes and seconds
  def minutes_and_seconds(seconds)
    return [0, 0] unless seconds > 0
    [seconds / 60, seconds % 60]
  end

  def selection_class(draft, selection)
    classes = ["c-draft__board__slot"]
    if selection.position
      classes << "c-draft__board__slot--" +
        selection.position.downcase
    end
    if draft.current_selection == selection
      classes << "c-draft__board__slot--current"
    end
    classes.join(" ")
  end
end
