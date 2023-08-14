# == Schema Information
#
# Table name: selections
#
#  id                :bigint           not null, primary key
#  ended_at          :datetime
#  pick_number       :integer
#  started_at        :datetime
#  write_in_name     :string
#  write_in_position :string
#  write_in_team     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  draft_id          :bigint           not null
#  player_id         :bigint
#  round_id          :bigint           not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_selections_on_draft_id   (draft_id)
#  index_selections_on_player_id  (player_id)
#  index_selections_on_round_id   (round_id)
#  index_selections_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (draft_id => drafts.id)
#  fk_rails_...  (player_id => players.id)
#  fk_rails_...  (round_id => rounds.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Selection, type: :model do
  context "instance methods" do
    it "update_and_advance"
    it "is_missed?"
    it "is_time_expired?"
    it "position"
    it "name"
    it "is_selected?"
    it "set_start"
    it "set_end"
    it "time_remaining"
    it "seconds_remaining"
  end
end
