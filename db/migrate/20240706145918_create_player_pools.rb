class CreatePlayerPools < ActiveRecord::Migration[7.1]
  def change
    create_table :player_pools do |t|

      t.timestamps
    end

    add_reference :players, :player_pool,
      null: false, foreign_key: true, default: 1
    add_reference :drafts, :player_pool,
      null: false, foreign_key: true, default: 1
  end
end
