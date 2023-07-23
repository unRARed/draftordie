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
    team { "GB" }
    name { "Aaron Rodgers" }
    position { "QB" }
    bye_week { 1 }
  end
end
