class UpdateDataSelectionsForDisplaysToVersion3 < ActiveRecord::Migration[7.0]
  def change
  
    update_view :data_selections_for_displays, version: 3, revert_to_version: 2
  end
end
