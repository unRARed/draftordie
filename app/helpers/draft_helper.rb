module DraftHelper
  # converts a number of seconds into a
  # tuple of minutes and seconds
  def minutes_and_seconds(seconds)
    return [0, 0] unless seconds > 0
    [(seconds / 60).floor, (seconds % 60).floor]
  end

  def pick_class(selection, user)
    classes = ["c-draft__pick"]
    if selection == selection.draft.current_selection
      classes << "c-draft__pick--current"
    end
    # classes << "c-draft__pick--mine" if selection.user == user
    classes << "c-draft__pick--missed" if selection.is_missed?
    classes.join(" ")
  end

  def draft_board_slot_class(selection)
    classes = ["c-draft__board__slot"]
    if selection.position
      classes << "c-draft__board__slot--" +
        selection.position.downcase
    end
    if selection.is_selected?
      classes << "c-draft__board__slot--selected"
    end
    if selection.draft.is_running? && selection.draft.current_selection == selection
      classes << "c-draft__board__slot--current"
    end
    classes.join(" ")
  end

  def compute_text_size(user_count)
    case user_count
    when 15..20
      7
    when 11..14
      8
    when 7..10
      10
    else
      14
    end
  end

  def build_draft_navigation
    return unless current_user
    return unless draft = @draft || @selection&.draft

    @navigation.add_item(:draft, NavigationItem.new(
        session[:is_sound_enabled] ?
          'Disable Sound' : 'Enable Sound',
        toggle_sound_draft_path(draft),
        data: { turbo: false }
      )
    )
    if draft.users.include?(current_user)
      if draft.is_running?
        @navigation.add_item(:draft, NavigationItem.new(
            'Dashboard', draft_path(draft)
          )
        )
      end
    else
      @navigation.add_item(:draft, NavigationItem.new(
          'Join this Draft', join_draft_path(draft)
        )
      )
    end
    @navigation.add_item(:draft, NavigationItem.new(
        "Board", board_draft_path(draft)
      )
    )
    if policy(draft).commish?
      @navigation.add_item(:draft, NavigationItem.new(
          'Setup', edit_draft_path(draft), data: { turbo: false }
        )
      )
      @navigation.add_item(:draft, NavigationItem.new(
          'Edit Selections',
          bulk_edit_draft_selections_path(draft),
          data: { turbo: false }
        )
      )
    end

    if current_user.drafts.length > 1
      @navigation.add_item(:draft, NavigationItem.new(
        "My Drafts", drafts_path)
      )
    end
  end
end
