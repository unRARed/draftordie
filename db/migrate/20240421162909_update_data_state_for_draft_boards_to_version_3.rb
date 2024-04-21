class UpdateDataStateForDraftBoardsToVersion3 < ActiveRecord::Migration[7.1]
  def change
    update_view :data_state_for_draft_boards, version: 3, revert_to_version: 2
  end
end
