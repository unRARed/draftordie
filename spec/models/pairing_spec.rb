# == Schema Information
#
# Table name: pairings
#
#  id            :bigint           not null, primary key
#  context       :text
#  pairable_type :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pairable_id   :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_pairings_on_pairable  (pairable_type,pairable_id)
#  index_pairings_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Pairing, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
