class Draft < ApplicationRecord
  before_save :generate_slug, :generate_access_code
  belongs_to :user

  has_many :rounds, dependent: :destroy
  has_many :selections,
    -> { order(pick_number: :asc)},
    through: :rounds
  has_many :upcoming_selections, -> {
      where(ended_at: nil)
    },
    through: :rounds,
    source: :selections
  has_many :pairings, as: :pairable
  has_many :users, through: :pairings

  validates :name, presence: true
  validates :round_count, :player_count, :selection_seconds,
    numericality: { greater_than: 0 }
  validates :round_count,
    numericality: { less_than_or_equal_to: 30 }
  validates :player_count,
    numericality: { less_than_or_equal_to: 20 }

  scope :preloaded, -> {
    eager_load(:users).eager_load(rounds: { selections: :user })
  }

  def is_started?
    started_at.present?
  end

  def selections_count
    selections.count{ |s| s.is_selected? }
  end

  def current_selection
    upcoming_selections.first
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
      current_pick_number = 1
      rounds.destroy_all unless rounds.empty?
      update started_at: nil, ended_at: nil
      attached_users = users
      round_count.times do |num|
        round_number = num + 1
        round = rounds.create(
          number: round_number,
          is_reversed: round_number.even?
        )

        # Create selections for the round
        attached_users = attached_users.reverse if round.is_reversed?
        attached_users.each do |attached_user|
          round.selections.create(
            user: attached_user,
            pick_number: current_pick_number
          )
          current_pick_number += 1
        end
      end
    end
  end

  def generate_slug
    return if slug.present?

    value ||= SecureRandom.alphanumeric(5).downcase
    unless Draft.where(slug: value).exists?
      self.slug = value
      return
    end

    generate_slug
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
end
