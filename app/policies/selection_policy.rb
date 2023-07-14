class SelectionPolicy < ApplicationPolicy
  def update?
    record.draft&.current_selection&.user == user
  end

  def edit?
    update?
  end
end
