class CreateDataStateForDraftBoards < ActiveRecord::Migration[7.0]
  def change
    create_view :data_state_for_draft_boards
  end
end
