class CreatePlayerPools < ActiveRecord::Migration[7.1]
  def change
    create_table :player_pools do |t|

      t.timestamps
    end

    PlayerPool.create!

    add_reference :players, :player_pool,
      null: false, foreign_key: true, default: PlayerPool.first.id
    add_reference :drafts, :player_pool,
      null: false, foreign_key: true, default: PlayerPool.first.id
  end
end
