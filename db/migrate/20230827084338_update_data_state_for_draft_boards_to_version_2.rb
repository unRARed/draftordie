class UpdateDataStateForDraftBoardsToVersion2 < ActiveRecord::Migration[7.0]
  def change
  
    update_view :data_state_for_draft_boards, version: 2, revert_to_version: 1
  end
end
