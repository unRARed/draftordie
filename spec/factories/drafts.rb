FactoryBot.define do
  factory :draft do
    name {
      Faker::Lorem.unique.words(number: 3).join(" ").titleize
    }
    round_count { 2 }
    player_count { 4 }
    selection_seconds { 5 }
    user
    # slug
  end

  trait :max do
    round_count { 20 }
    player_count { 16 }
  end

  trait :fast do
    selection_seconds { 1 }
  end
end
