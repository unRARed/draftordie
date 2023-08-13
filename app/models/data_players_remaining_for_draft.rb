# == Schema Information
#
# Table name: data_players_remaining_for_drafts
#
#  is_selected    :boolean
#  player_data    :text
#  value_for_sort :text
#  draft_id       :bigint
#  player_id      :bigint
#
class DataPlayersRemainingForDraft < ApplicationRecord
  belongs_to :draft
end
