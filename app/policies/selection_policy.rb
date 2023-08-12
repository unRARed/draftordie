class SelectionPolicy < ApplicationPolicy
  def bulk_edit?
    record.draft&.user == user
  end

  def update?
    record.draft&.user == user ||
      record.draft&.current_selection&.user == user
  end

  def edit?
    update?
  end
end
