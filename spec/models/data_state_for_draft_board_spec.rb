# == Schema Information
#
# Table name: data_state_for_draft_boards
#
#  current_pick_number       :integer
#  current_selection_ends_at :datetime
#  draft_slug                :string
#  is_selected               :boolean
#  now                       :timestamptz
#  current_selection_id      :bigint
#  draft_id                  :bigint
#  next_selection_id         :bigint
#  prior_selection_id        :bigint
#
require 'rails_helper'

RSpec.describe DataStateForDraftBoard, type: :model do
  subject { DataStateForDraftBoard.all }

  it "returns an array-like ActiveRecord::Relation" do
    expect(subject).to be_a_kind_of(ActiveRecord::Relation)
  end

  context "during active draft" do
    let!(:player_pool) { FactoryBot.create(:player_pool) }
    let!(:players) { 10.times{ FactoryBot.create :player } }
    let!(:draft) do
      FactoryBot.create :draft, :fast, :complete_commish_only,
        player_pool: player_pool
    end
    subject { DataStateForDraftBoard.all.first }

    it "flips the is_selected bool based on datetime" do
      pending "fails to do this in the test database"
      draft.generate_board!
      draft.activate!
      expect(
        DataStateForDraftBoard.all.first.is_selected
      ).to eq false
      expect(
        draft.upcoming_selections.first.started_at
      ).not_to be_nil
      expect(
        draft.upcoming_selections.first.started_at
      ).not_to be_nil
      current_selection_id = subject.current_selection_id
      expect(draft.upcoming_selections.length).to eq(2)
      travel_to 3.seconds.from_now
      # GOTCHA: the localtimestamp / CURRENT_TIMESTAMP via
      # postgres works in dev/prod, but it caches the value
      # on test annoyingly, so the is_selected bool DOES NOT
      # flip / can't rely on it. Refactoring to use:
      #
      #   @progression.ready_to_advance?
      #
      expect(
        DataStateForDraftBoard.all.reload.first.is_selected
      ).to eq true
    end
  end
end
