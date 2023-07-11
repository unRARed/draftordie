class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :board]

  def home; end
  def board
    @data = {
      round_count: 17,
      player_count: 16,
    }
  end
end
