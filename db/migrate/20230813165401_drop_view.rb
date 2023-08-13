class DropView < ActiveRecord::Migration[7.0]
  def change
    drop_view :view_draft_progression_candidates,
      revert_to_version: 2
  end
end
