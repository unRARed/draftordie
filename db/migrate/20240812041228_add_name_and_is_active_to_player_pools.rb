class AddNameAndIsActiveToPlayerPools < ActiveRecord::Migration[7.1]
  def change
    add_column :player_pools, :name, :string
    add_column :player_pools, :is_active, :boolean, default: true

    PlayerPool.all.each do |pool|
      pool.update!(name: "Football #{SecureRandom.hex(4)}")
    end

    add_index :player_pools, :name, unique: true
  end
end
