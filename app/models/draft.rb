# == Schema Information
#
# Table name: drafts
#
#  id                :bigint           not null, primary key
#  access_code       :string
#  ended_at          :datetime
#  is_paused         :boolean          default(FALSE), not null
#  name              :string           default(""), not null
#  round_count       :integer
#  selection_seconds :integer
#  slug              :string
#  started_at        :datetime
#  user_count        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_drafts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Draft < ApplicationRecord
  before_save :generate_slug, :generate_access_code
  belongs_to :user
  # belongs_to :current_selection,
  #   class_name: "Selection",
  #   optional: true

  has_one :progression,
    class_name: "ViewDraftProgressionCandidate"
  has_many :rounds, dependent: :destroy
  has_many :selections,
    -> { order(pick_number: :asc)},
    through: :rounds
  has_many :prior_selections,
    -> { where.not(ended_at: nil).order(pick_number: :desc) },
    class_name: "Selection"
  has_many :upcoming_selections,
    -> { where(ended_at: nil).order(pick_number: :asc) },
    class_name: "Selection"
  has_many :pairings, as: :pairable
  has_many :users, through: :pairings

  validates :name, presence: true
  validates :round_count, :user_count, :selection_seconds,
    numericality: { greater_than: 0 }
  validates :round_count,
    numericality: { less_than_or_equal_to: 30 }
  validates :user_count,
    numericality: { less_than_or_equal_to: 20 }

  scope :preloaded, -> {
    eager_load(:users).eager_load(rounds: { selections: :user })
  }

  def self.user_ids_for(draft)
    joins(:users).
      distinct.
      where(id: draft.id).
      pluck("drafts.user_id", "users.id").
      flatten.uniq
  end

  def remaining_players
    Player.for_selection.where(
      id: Player.all.pluck(:id) - self.selections.
        pluck(:player_id).compact
    )
  end

  def includes_user?(user)
    Draft.user_ids_for(self).
      include?(user.id)
  end

  def is_started?
    started_at.present?
  end

  def is_ended?
    ended_at.present? || upcoming_selections.empty?
  end

  def is_running?
    is_started? && !is_ended? && !is_paused?
  end

  def selections_count
    selections.count{ |s| s.is_selected? }
  end

  def current_selection
    progression&.current_selection
  end

  def next_selection
    progression&.next_selection
  end

  # To determine if the draft is between selections,
  # so we know whether to start the next selection
  def is_between_selections?
    return false if upcoming_selections.empty?
    return false unless !current_selection.nil?

    current_selection.time_remaining == [0, 0]
  end

  def to_param
    slug
  end

  def generate_board
    Draft.transaction do
      is_reversed = false
      current_pick_number = 1
      round_number = 1
      rounds.destroy_all unless rounds.empty?
      update started_at: nil, ended_at: nil, is_paused: false
      round_count.times do |num|
        round = rounds.create(
          number: round_number,
          is_reversed: is_reversed
        )

        # Create selections for the round
        #
        ordered_users = is_reversed ?
          self.users.reverse : self.users
        ordered_users.each do |ordered_user|
          round.selections.create(
            user: ordered_user,
            pick_number: current_pick_number,
            draft: self
          )
          current_pick_number += 1
        end
        round_number += 1
        is_reversed = !is_reversed
      end
    end
  end

  def generate_access_code
    return if access_code.present?

    value ||= [*('A'..'Z')].sample(4).join
    unless Draft.where(access_code: value).exists?
      self.access_code = value
      return
    end

    generate_access_code
  end

private

  def generate_slug
    return if slug.present?

    value ||= SecureRandom.alphanumeric(5).downcase
    unless Draft.where(slug: value).exists?
      self.slug = value
      return
    end

    generate_slug
  end
end
