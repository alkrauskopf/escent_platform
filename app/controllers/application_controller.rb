class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery

  # Accesses the current registrant from the session.
  def current_user
    @current_user ||= (session[:user_id] && User.find(session[:user_id]) rescue nil) || nil
  end

  def current_organization
    @current_organization ||= (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
  end

  def current_application
    @current_application ||= (CoopApp.find_by_public_id(params[:coop_app_id])) rescue CoopApp.core
  end

  #
  #    ELT Instance Variables
  #
  def current_elt_instances
    @current_case = EltCase.find_by_public_id(params[:elt_case_id]) rescue nil
    @current_cycle = @current_case.nil? ? nil : (@current_case.elt_cycle.nil? ? nil :@current_case.elt_cycle)
    @current_activity = @current_case.nil? ? nil : (@current_case.elt_type.nil? ? nil :@current_case.elt_type)
    @current_case_org = @current_case.nil? ? nil : (@current_case.organization.nil? ? nil :@current_case.organization)
  end

#
#  Tagging
#
  def toggle_classroom_favorite(user, classroom)
    authorization_level = AuthorizationLevel.first(:include => :applicable_scopes, :conditions => ["authorization_levels.name = ? AND applicable_scopes.name = ?", "favorite", "Classroom"])
    if authorization_level
      if user.has_favorite?(classroom)
        user.authorizations.find_by_scope_id_and_scope_type_and_authorization_level_id(classroom, classroom.class.to_s, authorization_level).destroy
      else
        user.add_as_favorite_to(classroom)        
      end
    end
  end

  def current_app_enabled_for_current_org?
    unless(@current_user && @current_user.superuser?) || @current_application.nil?
      if !@current_organization.allowed?(@current_application) || !@current_organization.app_enabled?(@current_application)
        redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => @current_organization, :coop_app_id => CoopApp.core
      end
    end
  end

  def current_user_classroom_authorized?
    unless(@current_user && @current_user.superuser?)
      if (@current_user.nil? || !@current_user.app_authorized?(CoopApp.classroom, @current_organization))
        redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => @current_organization, :coop_app_id => CoopApp.core
      end
    end
  end

  def user_authorize(auth_level)
     if @current_user.nil? || @current_organization.nil? || !@current_user.has_authority?(auth_level, @current_organization, :superuser=>true)
      organization = !@current_user.nil? ? @current_user.organization : Organization.default
      redirect_to :controller => "/site/site", :action => :static_organization, :organization_id => organization
     end
  end

  def authorized?(user, organization, authorization_level)

  end

  def clear_notice
    flash[:notice] = nil
    flash[:error] = nil
  end


  def update_app_settings(app, org, provider, selected, allowed, abbrev, name, provider_id)
    unless org.app_settings(app).nil?
      org.app_settings(app).update_attributes(:is_owner => provider, :is_selected => selected, :is_allowed => allowed, :alt_abbrev => abbrev, :alt_name => name, :provider_id => provider_id)
    else
      create_app_settings(app, org, provider, selected, allowed, abbrev, name, provider_id)
    end
  end

  def create_app_settings(app, org, provider, selected, allowed, abbrev, name, provider_id)
    if app.org_settings(org).nil?
      setting = CoopAppOrganization.new
      setting.organization_id = org.id
      setting.is_owner = provider
      setting.is_selected = selected
      setting.is_allowed = allowed
      setting.alt_abbrev = abbrev
      setting.alt_name = name
      setting.provider_id = provider_id
      app.coop_app_organizations<<setting
    end
  end

  def toggle_app_provider(app, provider)
    if provider.app_settings(app).nil?
      create_app_settings(app, provider, true, true, true, app.abbrev, app.name, provider.id)
    else
      abbrev = provider.app_settings(app).alt_abbrev.nil? ? app.abbrev : provider.app_settings(app).alt_abbrev
      name = provider.app_settings(app).alt_name.nil? ? app.name : provider.app_settings(app).alt_name
      if provider.app_settings(app).is_owner
        provider.provided_app_orgs(app,true).each do |org|
          update_app_settings(app, org, org.app_settings(app).is_owner, false, org.app_settings(app).is_allowed, '', '', nil)
          org.reset_org_option(app)
        end
        update_app_settings(app, provider, false, false, provider.app_settings(app).is_allowed, abbrev, name, nil)
      else
        provider.app_settings(app).update_attributes(:is_owner => !provider.app_settings(app).is_owner, :alt_abbrev => abbrev, :alt_name => name, :provider_id => provider.id)
        update_app_settings(app, provider, true, true, provider.app_settings(app).is_allowed, abbrev, name, nil)
      end
    end
  end

  def toggle_app_allow(app, org)
    if org.app_settings(app).nil?
      create_app_settings(app, org, false, false, false, app.abbrev, app.name, nil)
    else
      org.app_settings(app).update_attributes(:is_allowed => !org.app_settings(app).is_allowed)
    end
  end
end
