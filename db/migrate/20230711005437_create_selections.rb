class CreateSelections < ActiveRecord::Migration[7.0]
  def change
    create_table :selections do |t|
      t.references :draft, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :write_in_name
      t.string :write_in_position

      t.timestamps
    end
  end
end
