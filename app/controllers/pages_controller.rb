class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def home
    authorize :page
  end

  def docs
    authorize :page
  end
end
