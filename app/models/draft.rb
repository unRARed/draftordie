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
#  player_pool_id    :bigint           default(1), not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_drafts_on_player_pool_id  (player_pool_id)
#  index_drafts_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (player_pool_id => player_pools.id)
#  fk_rails_...  (user_id => users.id)
#
class Draft < ApplicationRecord
  before_save :generate_slug, :generate_access_code
  belongs_to :user
  belongs_to :player_pool
  # belongs_to :current_selection,
  #   class_name: "Selection",
  #   optional: true

  has_many :player_data,
    class_name: "DataPlayersRemainingForDraft"
  has_many :remaining_players,
    -> {
      where(
        "data_players_remaining_for_drafts.is_selected" => false
      ).
      order(
        position: :desc,
        value_for_sort: :asc
      )
    },
    through: :player_data,
    class_name: "Player"
  has_one :draft_board_state,
    class_name: "DataStateForDraftBoard"
  has_many :selections_for_display,
    class_name: "DataSelectionsForDisplay"
  has_many :rounds,
    -> { order(number: :asc) },
    dependent: :destroy
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
  has_many :team_name_pairings,
    -> { where("pairings.context" => "Draft Team Name") },
    class_name: "Pairing",
    as: :pairable
  has_many :order_pairings,
    -> {
      where("pairings.context" => "Draft Order").
        order(Arel.sql("NULLIF(regexp_replace(pairings.context_value, '\D', '', 'g'), '')::int") => :asc)
    },
    class_name: "Pairing",
    as: :pairable
  has_many :users, through: :team_name_pairings
  has_many :ordered_users,
    through: :order_pairings,
    source: :user

  validates :name, presence: true
  validates :round_count, :user_count, :selection_seconds,
    numericality: { greater_than: 0 }
  validates :round_count,
    numericality: { less_than_or_equal_to: 30 }
  validates :user_count,
    numericality: { less_than_or_equal_to: 20 }

  accepts_nested_attributes_for :order_pairings,
    reject_if: :all_blank
  accepts_nested_attributes_for :team_name_pairings,
    reject_if: ->(attributes){
      attributes["context_value"].blank?
    }

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

  def allocation
    "#{users.count} / #{user_count}"
  end

  def needs_draft_board_state?

  end

  def players_for_select(bulk = false)
    @players_for_select ||=
      {
        remaining: self.player_data.
          where(is_selected: false).
          map{|p| [p.player_data, p.player_id]},
        selected: self.player_data.
          where(is_selected: true).
          map{|p| [p.player_data, p.player_id]}
      }
  end
  # def remaining_players
  #   Player.for_selection.where(
  #     id: Player.all.pluck(:id) - self.selections.
  #       pluck(:player_id).compact
  #   )
  # end

  def includes_user?(user)
    Draft.user_ids_for(self).
      include?(user.id)
  end

  def is_started?
    started_at.present?
  end

  def remove_user(user)
    return false unless (data = self.pairings.where(user: user))

    Draft.transaction do
      data.destroy_all
    end
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
    draft_board_state&.current_selection ||
      remaining_selections.first
  end

  def next_selection
    draft_board_state&.next_selection
  end

  def remaining_selections
    selections.
      where(ended_at: nil).
      order(:pick_number)
  end

  # To determine if the draft is between selections,
  # so we know whether to start the next selection
  def is_between_selections?
    return false unless is_running?
    return false unless !current_selection.nil?

    current_selection.time_remaining == [0, 0]
  end

  def to_param
    slug
  end

  def generate_board!
    Draft.transaction do
      is_reversed = false
      current_pick_number = 1
      round_number = 1
      rounds.destroy_all unless rounds.empty?
      update started_at: nil, ended_at: nil, is_paused: false
      round_count.times do |num|
        round = rounds.create!(
          number: round_number,
          is_reversed: is_reversed
        )

        # Create selections for the round
        #

        users_ordered_for_board = ordered_users.present? ?
          self.ordered_users : self.users
        users_ordered_for_board = is_reversed ?
          users_ordered_for_board.reverse
          : users_ordered_for_board
        users_ordered_for_board.each do |ordered_user|
          round.selections.create!(
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

  # Turns the draft on, if not already
  def activate!
    # Prevent restarting an active draft
    return if started_at.present? && !is_paused

    transaction do
      # if started prior and currently only paused, we reset
      # the timer for the current selection and unpause
      if is_paused?
        current_selection.update started_at: Time.current
        update is_paused: false
      else
        update started_at: Time.current
        upcoming_selections.first.
          update_columns started_at: Time.current
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

  def fill_missed_selections
    Draft.transaction do
      missed_selections = self.selections.where(
        "player_id IS NULL AND write_in_name IS NULL"
      )
      player_ids = self.
        remaining_players.
        sample(missed_selections.count).
        pluck(:id)
      missed_selections.each_with_index do |selection, index|
        selection.update_columns(player_id: player_ids[index])
      end
    end
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
