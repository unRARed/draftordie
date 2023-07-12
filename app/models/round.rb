class Round < ApplicationRecord
  belongs_to :draft
  has_many :selections, dependent: :destroy
end
