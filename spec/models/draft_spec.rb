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
#  player_pool_id    :bigint           default(1), not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_drafts_on_player_pool_id  (player_pool_id)
#  index_drafts_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (player_pool_id => player_pools.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Draft, type: :model do
  subject { FactoryBot.build(:draft) }

  context "instance methods" do
    describe "#current_selection" do
      let!(:draft) { FactoryBot.create(:draft) }

      it "returns the next upcoming selection"
    end

    describe "#remaining_players" do
      it "excludes players not in the player_pool" do
        player_pool1 = FactoryBot.create(:player_pool)
        player_pool2 = FactoryBot.create(:player_pool)
        player1 = FactoryBot.
          create(:player, player_pool: player_pool1)
        player2 = FactoryBot.
          create(:player, player_pool: player_pool2)
        draft = FactoryBot.create(
          :draft,:complete_commish_only,
          player_pool: player_pool1
        )
        draft.generate_board!
        expect(draft.remaining_players.count).to eq(1)
        expect(draft.remaining_players).to include(player1)
        expect(draft.remaining_players).not_to include(player2)
      end
    end
  end
end
