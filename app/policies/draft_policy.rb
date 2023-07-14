class DraftPolicy < ApplicationPolicy
  # actions allowed for signed in users
  def new?
    create?
  end

  def create?
    user.present?
  end

  def access?
    create?
  end

  def verify_and_join?
    create?
  end

  def show?
    create?
  end

  # for specific attached user's view of the draft
  def member?
    is_draft_member?
  end

  # actions reserved for invted drafters
  def start_next_selection?
    is_draft_owner? || is_draft_member?
  end

  # actions reserved for the draft owner
  def start?
    is_draft_owner?
  end

  def edit?
    is_draft_owner?
  end

  def update?
    is_draft_owner?
  end

  def destroy?
    is_draft_owner?
  end

  def generate?
    is_draft_owner?
  end

  def start?
    is_draft_owner?
  end

  def invite?
    is_draft_owner?
  end

  def create_invite?
    is_draft_owner?
  end

private

  def is_draft_owner?
    user == record.user
  end

  def is_draft_member?
    record.users.include?(user)
  end
end
