FactoryBot.define do
  factory :selection do
    sequence(:pick_number) { |n| n }
    started_at { 1.second.ago }
    ended_at { nil }
    round
    user
  end

  trait :made do
    ended_at { 1.second.ago }
  end

  trait :selected do
    player
  end

  trait :wrote_in do
    write_in_name { "Joe Montana" }
    write_in_position { "QB" }
  end
end
