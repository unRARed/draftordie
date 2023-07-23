# == Schema Information
#
# Table name: selections
#
#  id                :bigint           not null, primary key
#  ended_at          :datetime
#  pick_number       :integer
#  started_at        :datetime
#  write_in_name     :string
#  write_in_position :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  draft_id          :bigint           not null
#  player_id         :bigint
#  round_id          :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_selections_on_draft_id   (draft_id)
#  index_selections_on_player_id  (player_id)
#  index_selections_on_round_id   (round_id)
#  index_selections_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (draft_id => drafts.id)
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (round_id => rounds.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :selection do
    sequence(:pick_number) { |n| n }
    started_at { 1.second.ago }
    ended_at { nil }
    draft
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
