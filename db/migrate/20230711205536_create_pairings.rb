class CreatePairings < ActiveRecord::Migration[7.0]
  def change
    create_table :pairings do |t|
      t.text :context
      t.references :user, null: false, foreign_key: true
      t.references :pairable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
