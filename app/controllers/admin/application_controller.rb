class Admin::ApplicationController < ApplicationController
  layout "site"
  include OrganizationRegistration
  
  before_filter :current_organization
  before_filter :current_user, :except => [:login]
  
# This doesn't work. Only Superusers pass through this filter 
#  require_authorization "administrator", :except => [:login , :show]
  
  def index
    update
    @features = Topic.features    
    @active_topics = @current_organization.topics.active
    @pending_topics = @current_organization.topics.pending
    @closed_topics = @current_organization.topics.closed
    @contents = @current_organization.contents.paginate :per_page => 10, :page => params[:page]
    @people = @current_organization.org_followers
    @blogs = @current_organization.blogs
    @reported_abuses = @current_organization.reported_abuses
    @active_classrooms = @current_organization.classrooms.active
    @archived_classrooms = @current_organization.classrooms.archived
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
