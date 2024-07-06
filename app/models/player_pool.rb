# == Schema Information
#
# Table name: player_pools
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PlayerPool < ApplicationRecord
  has_many :players
  has_many :drafts

  # NOTE: Re-generate football JSON player-list locally with:
  #
  #   RefreshPlayerPoolJob.perform_now
  #
  # Then import the JSON from console on prod like so:
  #
  #   PlayerPool.import("db/seeds/player_pools/20240706-football.json")
  #
  def self.import(path_to_json)
    pool = PlayerPool.create!

    JSON.parse(File.read(path_to_json)).each do |p|
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
end
