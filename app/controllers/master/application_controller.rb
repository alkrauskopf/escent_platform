class Master::ApplicationController < ApplicationController
  layout "master/crud"

#  include OrganizationRegistration
  
  before_filter :current_organization
  before_filter :current_user, :except => [:login]
  before_filter :current_application_core
  before_filter :superuser_authorize
  
  def index
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
      redirect_back_or_default :controller => "/master/application", :action => :index, :organization_id => @current_organization
    end
  end

  protected

  def current_application_core
    @current_application = CoopApp.core
  end
  def superuser_authorize
    if (@current_user.nil? || !@current_user.superuser?)
      redirect_to organization_view_path(:organization_id => Organization.default)
    end
  end

  def access_denied(message=nil)
    redirect_to organization_view_path(:organization_id => Organization.default)
  end

  def access_denied_old(message=nil)
 #   @login_url = url_for(:controller => "/master/application", :action => :login, "user[email_address]" => self.current_user ? @current_user.email_address : '', :organization_id => @current_organization)
    @login_url = organization_view_url(:organization_id => Organization.default)
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
