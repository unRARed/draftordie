class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :board]


  def home
    authorize :page, :home?
  end
end
