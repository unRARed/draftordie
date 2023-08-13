class CreateDataSelectionsForDisplays < ActiveRecord::Migration[7.0]
  def change
    create_view :data_selections_for_displays
  end
end
