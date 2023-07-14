FactoryBot.define do
  factory :selection do
    pick_number { 1 }
    write_in_name { nil }
    write_in_position { nil }
    started_at { 1.second.ago }
    ended_at { nil }
    round
    user
    player
  end
end
