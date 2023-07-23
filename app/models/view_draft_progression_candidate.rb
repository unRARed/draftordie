# == Schema Information
#
# Table name: view_draft_progression_candidates
#
#  current_pick_number  :integer
#  draft_slug           :string
#  is_selected          :boolean
#  current_selection_id :bigint
#  draft_id             :bigint
#  next_selection_id    :bigint
#  prior_selection_id   :bigint
#
class ViewDraftProgressionCandidate < ApplicationRecord
  belongs_to :draft

  def readonly?
    true
  end
end
