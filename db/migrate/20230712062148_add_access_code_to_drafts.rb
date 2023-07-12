class AddAccessCodeToDrafts < ActiveRecord::Migration[7.0]
  def change
    add_column :drafts, :access_code, :string, null: true
  end
end
