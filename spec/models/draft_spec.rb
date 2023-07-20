require 'rails_helper'

RSpec.describe Draft, type: :model do
  context :associations do
    let!(:draft) { FactoryBot.create(:draft) }
    let!(:round) { FactoryBot.create(:round, draft: draft) }

    describe :upcoming_sections do
      let!(:selection) { FactoryBot.create(:selection, round: round) }
      let!(:made_selection) { FactoryBot.create(:selection, :made, round: round) }

      it "returns selections that have not started" do
        expect(draft.upcoming_selections).
          to include(selection)
        expect(draft.upcoming_selections).
          not_to include(made_selection)
      end
    end
  end
  context "instance methods" do
    describe "#current_selection" do
      let!(:draft) { FactoryBot.create(:draft) }

      it "returns the next upcoming selection"
    end
  end
end
