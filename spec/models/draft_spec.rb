# == Schema Information
#
# Table name: drafts
#
#  id                :bigint           not null, primary key
#  access_code       :string
#  ended_at          :datetime
#  is_paused         :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  round_count       :integer
#  selection_seconds :integer
#  slug              :string
#  started_at        :datetime
#  user_count        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_drafts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
