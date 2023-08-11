class DraftPolicy < ApplicationPolicy
  # for anyone
  def access?
    true
  end

  def verify_access?
    true
  end

  def board?
    true
  end

  def show?
    true
  end

  # controls sound for the current session, draft board
  # likely not to be displayed by a logged-in user
  def toggle_sound?
    true
  end

  # for signed in users
  def create?
    user.present?
  end

  def new?
    create?
  end

  def join?
    create?
  end

  def leave?
    create?
  end

  def create_pairing?
    create?
  end

  # for specific attached user's view of the draft
  def member?
    is_participant?
  end

  # actions reserved for invted drafters
  def start_next_selection?
    is_commish? || is_participant?
  end

  # actions reserved for the draft owner
  def commish?
    is_commish?
  end

  def start?
    is_commish?
  end

  def pause?
    is_commish?
  end

  def edit?
    is_commish?
  end

  def update?
    is_commish?
  end

  def destroy?
    is_commish?
  end

  def generate?
    is_commish?
  end

  def start?
    is_commish?
  end

  def invite?
    is_commish?
  end

  def create_invite?
    is_commish?
  end

private

  def is_commish?
    user == record.user
  end

  def is_participant?
    record.users.include?(user)
  end
end
