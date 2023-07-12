class AddTimeColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :drafts, :is_paused, :boolean,
      null: false, default: false
    add_column :drafts, :started_at, :datetime
    add_column :drafts, :ended_at, :datetime
    add_column :rounds, :started_at, :datetime
    add_column :rounds, :ended_at, :datetime
    add_column :selections, :started_at, :datetime
    add_column :selections, :ended_at, :datetime
  end
end
