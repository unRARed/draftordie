# == Schema Information
#
# Table name: player_pools
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :player_pool do
    players { [] }
    drafts { [] }
  end
end
