class UpdateDataPlayersRemainingForDraftsToVersion3 < ActiveRecord::Migration[7.0]
  def change
  
    update_view :data_players_remaining_for_drafts, version: 3, revert_to_version: 2
  end
end
