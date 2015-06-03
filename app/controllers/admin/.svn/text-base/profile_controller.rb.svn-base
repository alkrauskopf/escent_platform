class Admin::ProfileController < Admin::ApplicationController
  layout "admin/profile/layout"

  before_filter     @organization = @current_organization  
  
  include OrganizationRegistration

  def index
    redirect_to :action => :register, :organization_id => @current_organization
  end
end
