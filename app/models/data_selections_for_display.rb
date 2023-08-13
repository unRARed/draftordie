# == Schema Information
#
# Table name: data_selections_for_displays
#
#  pick_number       :integer
#  player_data       :text
#  round_number      :integer
#  team_name         :string
#  write_in_name     :string
#  write_in_position :string
#  write_in_team     :string
#  draft_id          :bigint
#  player_id         :bigint
#  selection_id      :bigint
#
class DataSelectionsForDisplay < ApplicationRecord
  belongs_to :draft
  belongs_to :selection
end
