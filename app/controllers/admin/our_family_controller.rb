class Admin::OurFamilyController < Admin::ApplicationController
  layout "admin/our_family/layout", :except =>[ :people, :view_auth_members, :new_user_authorization]

  def index

  end
  
  def people
     @people = @current_organization.friends_of_org
  end
  
  def add_user_to_role
    if request.xhr?
      role = @current_organization.roles.find(params[:role_id])
      user = User.find_by_public_id(params[:user_id])
      user.roles << role unless role.users.include?(user)
      render :text => "#{user.full_name} successfully added to role #{role.name}."
    end
  end
  
  def export_x
    @role = @current_organization.roles.find(params[:id]) 
    
#    @users = @role.users.find(:all, :select => "first_name, last_name, preferred_email, postal_code")
    @users = @role.users
    respond_to do |format|
      format.html
      format.xml { render :xml => @users }
      format.xls { send_data @users.to_xls }
    end
    
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
  
  def authorization_levels
    #@authorization_levels = AuthorizationLevel.all(:conditions => ["id NOT IN (1, 3)"])
 #   @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'friend') AND applicable_scopes.name = ?", "Organization"])
    @authorization_levels = Organization.authorization_levels
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
    app = CoopApp.find_by_id(params[:app_id]) rescue nil
    authorization_level = AuthorizationLevel.find(params[:authorization_level]) rescue nil
    unless user.nil? || authorization_level.nil?
      if !user.has_authority?(@current_organization, authorization_level)
        if user.authorizations.create :authorization_level => authorization_level, :scope => @current_organization                      
          UserMailer.new_authorization(user, @current_organization, @current_user, authorization_level, request.host_with_port).deliver
        end
      else
        user_level = user.authorizations.for_level(authorization_level).for_entity(@current_organization).first rescue nil
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
      if !user.has_authority?(app, authorization_level)
        user.authorizations.create :authorization_level => authorization_level, :scope => app                           
      else
        user_level = user.authorizations.for_level(authorization_level).for_entity(@current_organization).first rescue nil
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
    render :layout => false
  end

end
