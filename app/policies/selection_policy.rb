class SelectionPolicy < ApplicationPolicy
  # Participant actions
  def edit_player_data?
    is_participant?
  end

  def update_player_data?
    is_participant?
  end

  # Commish actions
  def commish_edit?
    is_commish?
  end

  def update?
    is_commish?
  end

  def edit?
    is_commish?
  end

private

  def is_commish?
    record.draft&.user == user
  end

  def is_participant?
    record.draft&.current_selection&.user == user
  end
end
