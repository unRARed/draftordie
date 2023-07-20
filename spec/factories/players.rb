FactoryBot.define do
  factory :player do
    team { "GB" }
    name { "Aaron Rodgers" }
    position { "QB" }
    bye_week { 1 }
  end
end
