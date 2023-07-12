class Player < ApplicationRecord
  validates :name, :team, :position, :bye_week,
    presence: true

  validates :name,
    uniqueness: { scope: [:team, :position, :scraped_at] }

  delegate :name, to: :team, prefix: true
end
