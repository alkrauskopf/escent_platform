class OrganizationsController < ApplicationController
  layout "registration"
  include OrganizationRegistration
  
  before_filter :current_user
    
  def index
    redirect_to :action => :appearance
  end
  
  def no_user
    flash[:redirect] = "register"
  end
  
end

