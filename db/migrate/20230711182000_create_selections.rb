class CreateSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :selections do |t|
      t.references :round, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :player, null: true, foreign_key: true
      t.integer :pick_number
      t.string :write_in_name
      t.string :write_in_position

      t.timestamps
    end
  end
end
