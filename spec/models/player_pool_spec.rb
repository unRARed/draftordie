# == Schema Information
#
# Table name: player_pools
#
#  id         :bigint           not null, primary key
#  is_active  :boolean          default(TRUE)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_player_pools_on_name  (name) UNIQUE
#
require 'rails_helper'

RSpec.describe PlayerPool, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
