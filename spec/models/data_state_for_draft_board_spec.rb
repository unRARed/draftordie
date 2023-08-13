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
require 'rails_helper'

RSpec.describe DataStateForDraftBoard, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
