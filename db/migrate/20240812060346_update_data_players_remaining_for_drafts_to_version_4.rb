class UpdateDataPlayersRemainingForDraftsToVersion4 < ActiveRecord::Migration[7.1]
  def change
    update_view :data_players_remaining_for_drafts, version: 4, revert_to_version: 3
  end
end
