class PagePolicy < ApplicationPolicy
  def home?
    true
  end

  def docs?
    Rails.env.development?
  end
end
