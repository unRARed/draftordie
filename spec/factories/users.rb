FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email  }
    password { Faker::Internet.unique.password }
  end
end
