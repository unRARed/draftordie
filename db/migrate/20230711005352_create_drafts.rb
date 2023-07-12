class CreateDrafts < ActiveRecord::Migration[7.0]
  def change
    create_table :drafts do |t|
      # who created the draft
      t.references :user, null: false, foreign_key: true
      # the draft's unique identifier
      t.string :slug
      # the number of rounds in the draft
      t.integer :round_count
      # the number of players in the draft
      t.integer :player_count
      # the number of seconds each player has to make a selection
      t.integer :selection_seconds
      # all the users authorized to participate in the draft
      t.integer :user_ids, array: true, default: []

      t.timestamps
    end
  end
end
