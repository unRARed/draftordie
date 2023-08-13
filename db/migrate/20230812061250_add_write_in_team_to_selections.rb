class AddWriteInTeamToSelections < ActiveRecord::Migration[7.0]
  def change
    add_column :selections, :write_in_team, :string
  end
end
