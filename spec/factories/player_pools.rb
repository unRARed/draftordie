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
FactoryBot.define do
  factory :player_pool do
    name { Faker::Company.unique.bs.titleize }
    players { [] }
    drafts { [] }
  end

  factory :player_pool_with_players, parent: :player_pool do
    transient do
      players_count { 5 }
    end

    after(:create) do |player_pool, evaluator|
      create_list(:player,
        evaluator.players_count,
        player_pool: player_pool
      )
    end
  end
end
