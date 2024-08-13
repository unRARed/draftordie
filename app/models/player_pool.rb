# == Schema Information
#
# Table name: player_pools
#
#  id         :bigint           not null, primary key
#  is_active  :boolean          default(TRUE)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_player_pools_on_name  (name) UNIQUE
#
class PlayerPool < ApplicationRecord
  has_many :players
  has_many :drafts

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(is_active: true) }

  # NOTE: Re-generate football JSON player-list locally with:
  #
  #   RefreshPlayerPoolJob.perform_now
  #
  # Then import the JSON from console on prod like so:
  #
  #   PlayerPool.import(
  #     "2024 NFL",
  #     ["db/seeds/player_pools/20240706-football.json"]
  #   )
  #
  def self.import(name, paths)
    pool = PlayerPool.create!(name: name)

    paths.each do |path|
      JSON.parse(File.read(path)).each do |p|
        Player.create!(
          name: p["name"],
          team: p["team"],
          position: p["position"],
          bye_week: p["bye_week"],
          scraped_at: p["scraped_at"],
          player_pool: pool
        )
      end
    end
    pool
  end
end
