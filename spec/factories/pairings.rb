# == Schema Information
#
# Table name: pairings
#
#  id            :bigint           not null, primary key
#  context       :text
#  context_value :string
#  pairable_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pairable_id   :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_pairings_on_pairable  (pairable_type,pairable_id)
#  index_pairings_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :pairing do
    context { nil }
    pairable { nil }
  end

  trait :draft do
    pairable { FactoryBot.create(:draft) }
  end

  trait :team_context do
    context { "Draft Team Name" }
    context_value { Faker::Fantasy::Tolkien.character }
    pairable { FactoryBot.create(:draft) }
  end

  trait :order_context do
    context { "Draft Order" }
    context_value { Faker::Number.between(from: 1, to: 10) }
    pairable { FactoryBot.create(:draft) }
  end
end
