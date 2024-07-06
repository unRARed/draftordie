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
FactoryBot.define do
  factory :player do
    team { Player::TEAMS[:football].sample }
    name { Faker::Name.unique.name }
    position { Player::POSITIONS[:football].sample }
    bye_week { (4..14).to_a.sample }
  end
end
