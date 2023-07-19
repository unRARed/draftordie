class Round < ApplicationRecord
  belongs_to :draft
  has_many :selections,
    dependent: :destroy
  has_many :ordered_selections,
    -> { order(pick_number: :asc)},
    dependent: :destroy,
    class_name: "Selection"
end
