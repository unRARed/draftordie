# == Schema Information
#
# Table name: players
#
#  id         :bigint           not null, primary key
#  bye_week   :integer
#  name       :string
#  position   :string
#  scraped_at :datetime
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Player < ApplicationRecord
  validates :name, :team, :position, :bye_week,
    presence: true

  validates :name,
    uniqueness: { scope: [:team, :position, :scraped_at] }

  delegate :name, to: :team, prefix: true

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

  def formatted_name
    "(#{position}) #{name}"
  end

  # NOTE: re-generate football JSON player-list with:
  # RefreshPlayerPoolJob.perform_now
  def self.import_json(path_to_json)
    JSON.parse(File.read(path_to_json)).each do |p|
      Player.create!(
        name: p["name"],
        team: p["team"],
        position: p["position"],
        bye_week: p["bye_week"],
        scraped_at: p["scraped_at"],
      )
    end
  end
end
