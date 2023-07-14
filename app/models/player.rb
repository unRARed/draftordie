class Player < ApplicationRecord
  validates :name, :team, :position, :bye_week,
    presence: true

  validates :name,
    uniqueness: { scope: [:team, :position, :scraped_at] }

  delegate :name, to: :team, prefix: true

  scope :for_selection, -> {
    order(
      Arel.sql("position = 'QB' DESC"),
      Arel.sql("position = 'RB' DESC"),
      Arel.sql("position = 'WR' DESC"),
      Arel.sql("position = 'TE' DESC"),
      Arel.sql("position = 'DST' DESC"),
      Arel.sql("position = 'K' DESC"),
      :name
    )
  }
end
