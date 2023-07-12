class CreateRounds < ActiveRecord::Migration[7.0]
  def change
    create_table :rounds do |t|
      t.references :draft, null: false, foreign_key: true
      t.integer :number, null: false
      t.boolean :is_reversed, null: false, default: false

      t.timestamps
    end
  end
end
