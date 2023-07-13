class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  include Pundit::Authorization
  after_action :verify_authorized
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  skip_after_action :verify_authorized, if: :devise_controller?
  skip_after_action :verify_policy_scoped, if: :devise_controller?

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.
      permit(:sign_up, keys: %i[first_name last_name terms_and_conditions])
    devise_parameter_sanitizer.
      permit(:account_update, keys: %i[first_name last_name])
  end
end
