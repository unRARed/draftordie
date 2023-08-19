class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include ::LayoutsHelper

  before_action :configure_permitted_parameters,
    if: :devise_controller?
  before_action :authenticate_user!
  before_action :build_navigation

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  skip_after_action :verify_authorized, if: :devise_controller?
  skip_after_action :verify_policy_scoped, if: :devise_controller?

protected

  def build_navigation
    @navigation = Navigation.new(current_path: request.path)

    if current_user
      @navigation.add_item(:dynamic, NavigationItem.new(
          "Sign out",
          destroy_user_session_path,
          method: :delete, data: { turbo_method: :delete }
        )
      )
    else
      @navigation.add_item(:dynamic, NavigationItem.new(
          "Sign in", new_user_session_path
        )
      )
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.
      permit(:sign_up, keys: %i[first_name last_name terms_and_conditions])
    devise_parameter_sanitizer.
      permit(:account_update, keys: %i[first_name last_name])
  end
end
