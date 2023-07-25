class RenamePlayerCountToUserCountOnDrafts < ActiveRecord::Migration[7.0]
  def change
    rename_column :drafts, :player_count, :user_count
  end
end
