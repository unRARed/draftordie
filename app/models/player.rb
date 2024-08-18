# == Schema Information
#
# Table name: players
#
#  id             :bigint           not null, primary key
#  bye_week       :integer
#  name           :string
#  position       :string
#  scraped_at     :datetime
#  team           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  player_pool_id :bigint           default(1), not null
#
# Indexes
#
#  index_players_on_player_pool_id  (player_pool_id)
#
# Foreign Keys
#
#  fk_rails_...  (player_pool_id => player_pools.id)
#
class Player < ApplicationRecord
  include PgSearch::Model

  belongs_to :player_pool

  validates :name, :team, :position, :bye_week,
    presence: true

  validates :name,
    uniqueness: { scope: [:team, :position, :player_pool] }

  delegate :name, to: :team, prefix: true

  pg_search_scope :search_by_name,
    against: :name,
    using: {
      tsearch: { prefix: true }
    }

  POSITIONS = {
    football: %w[QB RB WR TE DST K],
  }

  TEAMS = {
    football: %w[
      ARI ATL BAL BUF CAR CHI CIN CLE DAL DEN DET
      GB HOU IND JAX KC LAC LAR LV MIA MIN NE NO
      NYG NYJ PHI PIT SEA SF TB TEN WAS
    ],
  }

  scope :latest, -> {
    select("players.*, DATE_TRUNC('month', scraped_at)").
    group("DATE_TRUNC('month', scraped_at), players.id")
    order(scraped_at: :desc)
  }

  scope :for_selection, -> {
    latest.
    order(Arel.sql("position DESC"), :name)
  }

  def formatted_name
    "#{name} (#{position}, #{team})"
  end
end
