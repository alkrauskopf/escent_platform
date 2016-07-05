class Admin::OurFamilyController < Admin::ApplicationController
  layout "admin/our_family/layout", :except =>[ :people, :view_auth_members, :new_user_authorization]

  def index

  end
  
  def people
     @people = @current_organization.friends_of_org
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
