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
class Round < ApplicationRecord
  belongs_to :draft
  has_many :selections,
    dependent: :destroy
  has_many :ordered_selections,
    -> { order(pick_number: :asc)},
    dependent: :destroy,
    class_name: "Selection"
end
