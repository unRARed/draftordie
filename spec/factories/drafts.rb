# == Schema Information
#
# Table name: drafts
#
#  id                :bigint           not null, primary key
#  access_code       :string
#  ended_at          :datetime
#  is_paused         :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  player_count      :integer
#  round_count       :integer
#  selection_seconds :integer
#  slug              :string
#  started_at        :datetime
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
