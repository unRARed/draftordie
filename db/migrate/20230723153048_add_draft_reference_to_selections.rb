class AddDraftReferenceToSelections < ActiveRecord::Migration[7.0]
  def change
    add_reference :selections, :draft,
      null: false, foreign_key: true
  end
end
