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
class Selection < ApplicationRecord
  BUFFER_SECONDS = 1

  include DraftHelper

  attr_accessor :selecting_user

  belongs_to :draft
  belongs_to :round
  belongs_to :user
  belongs_to :player, optional: true
  has_many :pairings,
    through: :draft

  has_one :pairing, -> (record) {
      where(pairable_type: "Draft").
      where(pairable_id: record.draft_id)
    },
    class_name: "Pairing",
    foreign_key: :user_id,
    primary_key: :user_id

  before_save :finalize_selection

  validates :player_id,
    uniqueness: {
      scope: :draft_id,
      message: "has already been selected in this draft",
      allow_nil: true
    }

  validate :write_in_values_mutually_present
  validate :xor_player_or_write_in

  after_update_commit -> {
    broadcast_update_later_to(
      self.draft,
      partial: "drafts/board",
      target: "board_#{self.draft.slug}",
      locals: {
        draft: self.draft,
        user: self.selecting_user,
        selection: draft&.current_selection
      }
    )
    broadcast_update_later_to(
      self.draft,
      partial: "drafts/show_picks",
      target: "show_picks_#{self.draft.slug}",
      locals: {
        draft: self.draft,
        user: self.selecting_user,
        selection: draft&.current_selection
      }
    )
    broadcast_update_later_to(
      self.draft,
      partial: "drafts/show_info",
      target: "show_info_#{self.draft.slug}",
      locals: {
        draft: self.draft,
        user: self.selecting_user,
        selection: draft&.current_selection
      }
    )
    # Shared
    broadcast_update_later_to(
      self.draft,
      partial: "drafts/footer",
      target: "footer_#{self.draft.slug}",
      locals: { draft: self.draft }
    )
  }

  delegate :position, :name,
    to: :player, allow_nil: true, prefix: true
  delegate :email, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :player, prefix: true, allow_nil: true
  delegate :draft_id, to: :round, allow_nil: false
  delegate :draft_slug, to: :round, allow_nil: false
  delegate :number, to: :round, prefix: true, allow_nil: false

  def update_and_advance(attributes)
    attributes = { ended_at: Time.current }.merge(attributes)

    self.transaction do
      next_selection = self.
        draft.progression.next_selection
      self.update(attributes)
      next_selection.update_columns(started_at: Time.current)
    end
  end

  def is_missed?
    ended_at.present? && player.blank? && write_in_name.blank?
  end

  def time_expired?
    ended_at.nil? && Time.current >
      (started_at + draft.selection_seconds.seconds)
  end

  def position
    return write_in_position if write_in_position.present?

    return player_position if player.present?
    ""
  end

  def name
    return write_in_name if write_in_name.present?

    return player.formatted_name if player.present?
    "Missed"
  end

  def is_selected?
    player.present? || write_in_name.present? || ended_at.present?
  end

  def set_start
    self.started_at = Time.current
  end

  def set_end
    self.ended_at = Time.current
  end

  def time_remaining
    unless self.started_at.present? && draft.started_at.present?
      return minutes_and_seconds(draft.selection_seconds)
    end
    [remaining_seconds] + minutes_and_seconds(seconds_remaining)
  end

  def seconds_remaining
    unless self.started_at.present? && draft.started_at.present?
      return draft.selection_seconds
    end
    elapsed_seconds = Time.current - self.started_at
    (draft.selection_seconds - elapsed_seconds) + BUFFER_SECONDS
  end

private

  def finalize_selection
    return if self.ended_at.present?
    return unless self.is_selected?

    self.set_end
  end

  def write_in_values_mutually_present
    return if write_in_name.blank? &&
      write_in_position.blank? &&
      write_in_team.blank?
    return if write_in_name.present? &&
      write_in_position.present? &&
      write_in_team.present?

    errors.add(:base,
      "Team, Position and Player Name required for write-ins.")
  end

  def xor_player_or_write_in
    return if player.nil? && write_in_name.blank?
    return if player.nil? && !write_in_name.blank?
    return if !player.nil? && write_in_name.blank?

    errors.add(:base,
      "Either select a player or write one in, not both.")
  end
end
