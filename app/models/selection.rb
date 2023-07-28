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
  include DraftHelper
  belongs_to :draft
  belongs_to :round
  belongs_to :user
  belongs_to :player, optional: true

  before_save :finalize_selection

  after_update_commit -> {
    broadcast_update_to(
      :draft_board,
      partial: "drafts/board",
      locals: { draft: self.draft },
      target: "board_#{self.draft.slug}"
    )
    broadcast_update_to(
      :draft_board,
      partial: "drafts/footer",
      locals: { draft: self.draft },
      target: "footer_#{self.draft.slug}"
    )
    broadcast_update_to(
      :draft_show,
      partial: "drafts/show",
      locals: { draft: self.draft },
      target: "show_#{self.draft.slug}"
    )
  }

  delegate :position, :name,
    to: :player, allow_nil: true, prefix: true
  delegate :email, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :player, prefix: true, allow_nil: true
  delegate :draft_id, to: :round, allow_nil: false
  delegate :draft_slug, to: :round, allow_nil: false

  def position
    return write_in_position if write_in_position.present?

    return player_position if player.present?
    ""
  end

  def name
    return write_in_name if write_in_name.present?

    return player_name if player.present?
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
    elapsed_seconds = Time.current - self.started_at
    remaining_seconds = draft.selection_seconds - elapsed_seconds
    [remaining_seconds] + minutes_and_seconds(remaining_seconds)
  end

  def seconds_remaining
    unless self.started_at.present? && draft.started_at.present?
      return draft.selection_seconds
    end
    elapsed_seconds = Time.current - self.started_at
    draft.selection_seconds - elapsed_seconds
  end

private

  def finalize_selection
    return if self.ended_at.present?
    return unless self.is_selected?

    self.set_end
  end
end
