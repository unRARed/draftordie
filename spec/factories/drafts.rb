# == Schema Information
#
# Table name: drafts
#
#  id                :bigint           not null, primary key
#  access_code       :string
#  ended_at          :datetime
#  is_paused         :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  round_count       :integer
#  selection_seconds :integer
#  slug              :string
#  started_at        :datetime
#  user_count        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_drafts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :draft do
    name {
      Faker::Lorem.unique.words(number: 3).join(" ").titleize
    }
    round_count { 2 }
    user_count { 4 }
    selection_seconds { 5 }
    user
    # slug

  end

  trait :max do
    round_count { 20 }
    user_count { 16 }
  end

  trait :fast do
    selection_seconds { 1 }
  end

  trait :started do
    started_at { 1.second.ago }
  end

  # trait :complete_and_ready_to_start do
  #   user_count { 4 }

  #   after(:create) do |draft, evaluator|
  #     draft.pairings << create(:pairing,
  #       :team_context, user: draft.user,
  #       context_value: "Commish's Team")
  #     target_users = []
  #     3.times{ target_users << create(:user) }

  #     target_users.each do |user|
  #       draft.pairings << create(:pairing,
  #         :team_context, user: user)
  #     end

  #     draft.generate_board!
  #   end
  # end

  trait :complete_commish_only do
    user_count { 1 }

    after(:create) do |draft, evaluator|
      draft.pairings << create(:pairing,
        :team_context, user: draft.user,
        context_value: "Commish's Team")
    end
  end
end
