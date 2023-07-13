class Round < ApplicationRecord
  belongs_to :draft
  has_many :selections,
    -> { order(pick_number: :asc)},
    dependent: :destroy
end
