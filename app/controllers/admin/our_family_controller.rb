class Admin::OurFamilyController < Admin::ApplicationController
  layout "admin/our_family/layout", :except =>[:view_members, :people, :view_auth_members, :new_user_authorization]
  
  def index

  end
  
  def people
 #   @people = User.find :all, :include => [:authorizations, :roles], :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ?) OR (roles.id IN (?))", @current_organization, "Organization", @current_organization.roles.collect{|r| r.id}]
     @people = User.who_are_friends(@current_organization)
  end
  

  def new
    @role = @current_organization.roles.new
    if request.post?
      @role = @current_organization.roles.new(params[:role])
      if @role.save
        flash[:notice] = "Successfully created role #{@role.name}."
        redirect_to :action => :roles, :organization_id => @current_organization
      else
        flash[:error] = @role.errors.full_messages.to_sentence
      end
    end
  end
  
  def add_user_to_role
    if request.xhr?
      role = @current_organization.roles.find(params[:role_id])
      user = User.find_by_public_id(params[:user_id])
      user.roles << role unless role.users.include?(user)
      render :text => "#{user.full_name} successfully added to role #{role.name}."
    end
  end
  
  def edit
    @role = @current_organization.roles.find(params[:id])
    if request.post?
      if @role.update_attributes(params[:role])
        flash[:notice] = "Successfully updated role #{@role.name}."
        redirect_to :action => :roles, :organization_id => @current_organization
      else
        flash[:error] = @role.errors.full_messages.to_sentence
      end
    end
  end
  
  def delete_user_from_role
    if request.post?
      role = @current_organization.roles.find(params[:role_id])
      user = User.find_by_public_id(params[:user_id])
      user.role_memberships.each do |rm|
        rm.destroy if rm.role == role
      end
      flash[:notice] = "#{user.full_name} successfully removed role #{role.name}."
      redirect_to :action => :roles, :organization_id => @current_organization
    end
  end
  
  def delete
    if request.post?
      @role = @current_organization.roles.find(params[:id])
      if @role.can_be_deleted?
        @role.destroy
        flash[:notice] = "Successfully removed role #{@role.name}."
      else
        flash[:error] = "Role #{@role.name} cannot be deleted!"
      end
      redirect_to :action => :roles, :organization_id => @current_organization
    end
  end
  
  def send_email
    @role = @current_organization.roles.find(params[:id])    
    if params[:email][:subject].empty? || params[:email][:message].empty?
      flash[:error] = "Subject and Message are required."
      render :template => "admin/our_family/email_role"           
    else
      @role.users.each {|user| Notifier.deliver_email_role(user.preferred_email, params[:email][:subject], params[:email][:message])}   
      flash[:notice] = "Message Sent"      
      render :template => "admin/our_family/roles"           
    end
  end
  
  def export
    @role = @current_organization.roles.find(params[:id]) 
    
    @users = @role.users.find(:all, :select => "first_name, last_name, preferred_email, postal_code")
    respond_to do |format|
      format.html
      format.xml { render :xml => @users }
      format.xls { send_data @users.to_xls }
    end
    
  end
  
  def email_role
    @role = @current_organization.roles.find(params[:id])
  end
  
  def view_members
    @role = @current_organization.roles.find params[:id]
  rescue ActiveRecord::RecordNotFound => e
    render :text => "<div>No users found.</div>" and return
  end
  
  def view_other_members
    @role = @current_organization.roles.find params[:id]
     @users_in_role = User.with_role(@role.id)
     @friends = User.who_are_friends(@current_organization)
     @users = @friends - @users_in_role
   
  rescue ActiveRecord::RecordNotFound => e
    render :text => "<div>No users found.</div>" and return
  end

#
# ALk This method returns Users for an Authorization for a particular Organization
  def view_auth_members
    @al = AuthorizationLevel.find(params[:id])
    if params[:scope]=="a"
      @app = CoopApp.find_by_id(params[:app_id])  
      @people = @app.authorized_users.find_all_by_authorization_level_id(@al)      
    else
      @people = @current_organization.authorized_users.find_all_by_authorization_level_id(@al)
    end
  rescue ActiveRecord::RecordNotFound => e
    render :text => "<div>No users found.</div>" and return
  end

  
  def remove_authentication_level
    user = User.find_by_public_id(params[:user_id])
    authorization_level =  AuthorizationLevel.find(params[:authentication_level_id])
    user.authorizations.each do |a|
      unless params[:app_id] == ""
        app = CoopApp.find_by_id(params[:app_id]) rescue nil
        a.destroy if (!app.nil? && a.authorization_level == authorization_level && a.scope_id == app.id)
      else
          a.destroy if (a.authorization_level == authorization_level && a.scope_id == @current_organization.id)
      end
    end
    flash[:notice] = "#{user.full_name} has been removed"
    redirect_to :action => :authorization_levels, :organization_id => @current_organization
  end
  
  def edit_user_toggle_suspended
    user = User.find_by_public_id(params[:id])
    if user.is_suspended
      user.suspend(false)
      flash[:notice] = "#{user.full_name} Suspension Removed"
    else
      user.suspend(true)    
      flash[:notice] = "#{user.full_name} Login Is Suspended"
    end
    redirect_to :action => :people, :organization_id => @current_organization
 end  
  
  
  def remove_association
    @user = User.find_by_public_id params[:id]
    @user.remove_as_friend_from @current_organization
    if @user.organization == @current_organization
      default_org = Organization.ep_default.first rescue nil
      if default_org
        @user.update_attributes(:home_org_id =>default_org.id, :organization_id => default_org.id)
      end
    end
    flash[:notice] = "#{@user.full_name} has been removed from this organization"
    redirect_to :action => :people, :organization_id => @current_organization
  end
  
  def contact
    @user = User.find_by_public_id params[:id]

    if request.post?
      Notifier.deliver_contact @current_user.preferred_email, params[:email_archive].merge(:user => @user)
      @people = User.find :all, :include => [:authorizations, :roles], :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ?) OR (roles.id IN (?))", @current_organization, "Organization", @current_organization.roles.collect{|r| r.id}]      
      respond_to do |format|
        format.js do
          responds_to_parent do
            render :update do |page|
              page.replace_html "our_family_panel", :file => 'admin/our_family/people', :object => @current_organization
            end
          end          
        end
      end
    end
  end
  
  def authorization_levels
    #@authorization_levels = AuthorizationLevel.all(:conditions => ["id NOT IN (1, 3)"])
    @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'friend') AND applicable_scopes.name = ?", "Organization"])  
  end
  
  def new_user_authorization_old
    #@authorization_levels = AuthorizationLevel.all(:conditions => ["id NOT IN (1, 3)"])
    @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'friend') AND applicable_scopes.name = ?", "Organization"])  
#   @people = User.find :all, :include => [:authorizations, :roles], :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ?) OR (roles.id IN (?))", @current_organization, "Organization", @current_organization.roles.collect{|r| r.id}]
     @people = User.who_are_friends(@current_organization)
    if request.post?
      user = User.find(params[:user])
      authorization_level = AuthorizationLevel.find(params[:authorization_level])
    if (user.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(@current_organization, @current_organization.class.to_s, authorization_level))
      redirect_to :action => :authorization_levels, :organization_id => @current_organization
      else
        if user.authorizations.create :authorization_level => authorization_level, :scope => @current_organization                      
        Notifier.deliver_new_authorization(:user => user, :current_organization => @current_organization, :admin => @current_user, :authorization_level => authorization_level, :fsn_host => request.host_with_port)          
        flash[:notice] = "Successfully added the user to authorization level: #{authorization_level.name}."
        redirect_to :action => :authorization_levels, :organization_id => @current_organization
        else
        flash[:notice] = "error"
        redirect_to :action => :authorization_levels, :organization_id => @current_organization
        end
      end
    end
  end

  def new_user_authorization
    @user = nil
  end

  def authorize_user
    user = User.find_by_public_id(params[:user_id]) rescue nil
    render :partial => "new_user_authorization", :locals => {:user => user}
  end

  def toggle_authorization
    user = User.find_by_public_id(params[:user_id]) rescue nil
    authorization_level = AuthorizationLevel.find(params[:authorization_level]) rescue nil
    unless user.nil? || authorization_level.nil?
      if !user.has_authorization_level_for?(@current_organization, authorization_level)
        if user.authorizations.create :authorization_level => authorization_level, :scope => @current_organization                      
          Notifier.deliver_new_authorization(:user => user, :current_organization => @current_organization, :admin => @current_user, :authorization_level => authorization_level, :fsn_host => request.host_with_port)          
        end     
      else
        user_level = user.authorizations.for_level(@current_organization, authorization_level).first rescue nil
        user_level.destroy unless user_level.nil?
      end
    end
    render :partial => "new_user_authorization", :locals => {:user => user}
  end

  def toggle_app_authorization
    user = User.find_by_public_id(params[:user_id]) rescue nil
    app = CoopApp.find_by_id(params[:app_id]) rescue nil
    authorization_level = AuthorizationLevel.find(params[:authorization_level]) rescue nil
    unless user.nil? || authorization_level.nil?
      if !user.has_authorization_level_for?(app, authorization_level)
        user.authorizations.create :authorization_level => authorization_level, :scope => app                           
      else
        user_level = user.authorizations.for_level(app, authorization_level).first rescue nil
        user_level.destroy unless user_level.nil?
      end
    end
    render :partial => "new_user_authorization", :locals => {:user => user}
  end



  def unverified_users
    @users = User.unverified_users
  end
  
  def verified
    @user = User.find params[:user_id]
    @user.set_verified
    unverified_users
    Notifier.deliver_user_registration @user, request.host_with_port, true
    render :layout => false 
  end
end
