class CreateViewDraftProgressionCandidates < ActiveRecord::Migration[7.0]
  def change
    create_view :view_draft_progression_candidates
  end
end
