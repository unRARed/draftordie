# == Schema Information
#
# Table name: players
#
#  id         :bigint           not null, primary key
#  bye_week   :integer
#  name       :string
#  position   :string
#  scraped_at :datetime
#  team       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Player, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
