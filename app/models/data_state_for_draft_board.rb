# == Schema Information
#
# Table name: data_state_for_draft_boards
#
#  current_pick_number  :integer
#  draft_slug           :string
#  is_selected          :boolean
#  current_selection_id :bigint
#  draft_id             :bigint
#  next_selection_id    :bigint
#  prior_selection_id   :bigint
#
class DataStateForDraftBoard < ApplicationRecord
  belongs_to :draft

  belongs_to :current_selection,
    foreign_key: :current_selection_id,
    class_name: "Selection"
  belongs_to :next_selection,
    foreign_key: :next_selection_id,
    class_name: "Selection"
  belongs_to :prior_selection,
    foreign_key: :prior_selection_id,
    class_name: "Selection"

  def readonly?
    true
  end
end
