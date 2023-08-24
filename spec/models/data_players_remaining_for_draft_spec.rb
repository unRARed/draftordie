# == Schema Information
#
# Table name: data_players_remaining_for_drafts
#
#  id             :bigint           primary key
#  is_selected    :boolean
#  player_data    :text
#  value_for_sort :text
#  draft_id       :bigint
#
require 'rails_helper'

RSpec.describe DataPlayersRemainingForDraft, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
