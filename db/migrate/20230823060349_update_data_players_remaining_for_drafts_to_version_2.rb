class UpdateDataPlayersRemainingForDraftsToVersion2 < ActiveRecord::Migration[7.0]
  def change
    update_view :data_players_remaining_for_drafts, version: 2, revert_to_version: 1
  end
end
