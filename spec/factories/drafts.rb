FactoryBot.define do
  factory :draft do
    slug { "MyString" }
    round_count { 1 }
    player_count { 1 }
    selection_seconds { 1 }
  end
end
