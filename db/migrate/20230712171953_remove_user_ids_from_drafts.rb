class RemoveUserIdsFromDrafts < ActiveRecord::Migration[7.0]
  def change
    remove_column :drafts, :user_ids, :integer, array: true, default: []
  end
end
