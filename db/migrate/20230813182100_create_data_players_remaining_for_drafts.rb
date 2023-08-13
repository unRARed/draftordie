class CreateDataPlayersRemainingForDrafts < ActiveRecord::Migration[7.0]
  def change
    create_view :data_players_remaining_for_drafts
  end
end
