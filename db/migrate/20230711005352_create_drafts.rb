class CreateDrafts < ActiveRecord::Migration[7.0]
  def change
    create_table :drafts do |t|
      t.string :slug
      t.integer :round_count
      t.integer :player_count
      t.integer :selection_seconds
      t.integer :player_ids, array: true, default: []

      t.timestamps
    end
  end
end
