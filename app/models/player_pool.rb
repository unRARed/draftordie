# == Schema Information
#
# Table name: player_pools
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PlayerPool < ApplicationRecord
  has_many :players
  has_many :drafts
end
