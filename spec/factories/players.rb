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
FactoryBot.define do
  factory :player do
    team { Player::TEAMS[:football].sample }
    name { Faker::Name.unique.name }
    position { Player::POSITIONS[:football].sample }
    bye_week { (4..14).to_a.sample }
  end
end
