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
end
