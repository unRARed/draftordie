class UpdateDataSelectionsForDisplaysToVersion2 < ActiveRecord::Migration[7.0]
  def change
  
    update_view :data_selections_for_displays, version: 2, revert_to_version: 1
  end
end
