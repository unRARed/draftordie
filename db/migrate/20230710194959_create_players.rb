class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name
      t.string :team
      t.string :position
      t.integer :bye_week
      t.datetime :scraped_at

      t.timestamps
    end
  end
end
