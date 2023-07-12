class Pairing < ApplicationRecord
  belongs_to :user
  belongs_to :pairable, polymorphic: true
end
