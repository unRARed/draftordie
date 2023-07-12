class AddNameToDrafts < ActiveRecord::Migration[7.0]
  def change
    add_column :drafts, :name, :string, null: false, default: ""
  end
end
