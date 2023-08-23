# == Schema Information
#
# Table name: data_players_remaining_for_drafts
#
#  id             :bigint
#  is_selected    :boolean
#  player_data    :text
#  value_for_sort :text
#  draft_id       :bigint
#
class DataPlayersRemainingForDraft < ApplicationRecord
  self.primary_key = :id

  belongs_to :draft
  has_many :remaining_players,
    foreign_key: :id,
    class_name: "Player"
end
