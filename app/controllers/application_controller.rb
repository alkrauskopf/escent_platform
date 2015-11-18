class ApplicationController < ActionController::Base
  protect_from_forgery

  # Accesses the current registrant from the session.
  def current_user
    @current_user ||= (session[:user_id] && User.find(session[:user_id]) rescue nil) || nil
  end

  def current_organization
    @current_organization ||= (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
  end

end
