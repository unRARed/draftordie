class Selection < ApplicationRecord
  include DraftHelper
  belongs_to :round
  belongs_to :user
  belongs_to :player, optional: true
  has_one :draft, through: :round

  before_save :finalize_selection

  delegate :position, :name,
    to: :player, allow_nil: true, prefix: true
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :player, prefix: true, allow_nil: true

  def position
    return write_in_position if write_in_position.present?

    return player_position if player.present?
    ""
  end

  def name
    return write_in_name if write_in_name.present?

    return player_name if player.present?
    ""
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
    elapsed_seconds = Time.current - self.started_at
    minutes_and_seconds(draft.selection_seconds - elapsed_seconds)
  end

private

  def finalize_selection
    return if self.ended_at.present?
    return unless self.is_selected?

    self.set_end
  end
end
