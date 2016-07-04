class Admin::ApplicationController < ApplicationController
  layout "site"
#  include OrganizationRegistration
  
  before_filter :current_organization
  before_filter :current_user, :except => [:login]
  before_filter :core_enabled_for_current_org?
  before_filter :org_admin_authorize

# This doesn't work. Only Superusers pass through this filter 
#  require_authorization "administrator", :except => [:login , :show]



  def index
    @organization = @current_organization
    @address = @organization.addresses.first || @organization.addresses.new
  end

  def login
    @email_address = params[:user][:email_address]
    
    if request.post?
      if user = User.authenticate(params[:user][:email_address], params[:user][:password])
        self.current_user = user
        flash[:notice]  = "Sign-in Successful"
      else
        flash[:error] = "Sign-in Unsuccessful"
      end
      redirect_back_or_default :controller => "/admin/application", :action => :index, :organization_id => @current_organization
    end
  end

  protected

  def org_admin_authorize
    user_authorize(AuthorizationLevel.app_administrator(CoopApp.core))
  end

  def access_denied(message=nil)
    @login_url = url_for(:controller => "/admin/application", :action => :login, "user[email_address]" => self.current_user ? @current_user.email_address : '', :organization_id => @current_organization)
    #untrack_administrator
    self.current_user = nil
    
    flash[:error] = message unless message.blank?
    respond_to do |format|
      format.html { (redirect_to @login_url and return false) }
      format.js do
        render :update do |p|
          p << "location.href = '#{@login_url}';"
        end and return false
      end
    end
    false
  rescue ActionController::DoubleRenderError
    false
  end
end
