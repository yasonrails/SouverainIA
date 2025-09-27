class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # before_action :authenticate_user! # Disabled for demo

  def current_user
    @current_user ||= User.find_by(email: 'demo@souverainia.fr')
  end

  def user_signed_in?
    current_user.present?
  end

  helper_method :current_user, :user_signed_in?
end
