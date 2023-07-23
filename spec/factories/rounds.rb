# == Schema Information
#
# Table name: rounds
#
#  id          :bigint           not null, primary key
#  ended_at    :datetime
#  is_reversed :boolean          default(FALSE), not null
#  number      :integer          not null
#  started_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  draft_id    :bigint           not null
#
# Indexes
#
#  index_rounds_on_draft_id  (draft_id)
#
# Foreign Keys
#
#  fk_rails_...  (draft_id => drafts.id)
#
FactoryBot.define do
  factory :round do
    draft { nil }
    number { 1 }
    is_reversed { false }
  end
end
