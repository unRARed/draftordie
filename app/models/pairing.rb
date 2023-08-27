# == Schema Information
#
# Table name: pairings
#
#  id            :bigint           not null, primary key
#  context       :text
#  context_value :string
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
class Pairing < ApplicationRecord
  belongs_to :user,
    inverse_of: :pairings
  belongs_to :pairable, polymorphic: true

  validate :maximum_slots
  validates :context_value,
    presence: true,
    uniqueness: {
      scope: [
        :pairable_type, :pairable_id, :context, :context_value
      ],
      message: "Team Name is already taken for this draft."
    },
    if: -> { context == "Draft Team Name" }

  def for_draft(draft)
    pairable == draft
  end

  def team_name
    return nil unless context == "Draft Team Name"
    context_value
  end

private

  def maximum_slots
    return unless context == "Draft Order"
    return unless pairable_type == "Draft"
    return unless pairable_id.present?
    return unless context_value.present?

    ordered_count = pairable.order_pairings.count
    team_count = pairable.team_name_pairings.count

    return unless ordered_count >= team_count
    return if pairable.order_pairings.include?(self)

    pairable.errors.add(:base, "Draft Order out of range.")
  end
end
