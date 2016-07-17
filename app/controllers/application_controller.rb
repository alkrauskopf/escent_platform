class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include SimpleCaptcha::ControllerHelpers

  protect_from_forgery

  before_filter :current_organization
  before_filter :current_user
  before_filter :current_application
  before_filter :core_enabled_for_current_org?


  def core_enabled_for_current_org?
    unless(@current_user && @current_user.superuser? || @current_organization.nil? || @current_organization == Organization.default)
      if !@current_organization.allowed?(CoopApp.core)
        redirect_to organization_view_path(:organization_id => Organization.default)
      end
    end
  end
  # Accesses the current registrant from the session.
  def current_user
    @current_user ||= (session[:user_id] && User.find(session[:user_id]) rescue nil) || nil
  end

  def current_organization
    @current_organization ||= (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
  end

  def current_application
    @current_application ||= CoopApp.find_by_public_id(params[:coop_app_id]) rescue CoopApp.core
  end

  def increment_app_views
    @current_application.increment_views
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
#  App Authorizations
#

  def current_org_current_app_provider?
    unless (!@current_organization.nil? && !@current_application.nil? && @current_organization.provider?(@current_application))
      org = @current_organization.nil? ? Organization.default : @current_organization
      redirect_to organization_view_path(:organization_id => org)
    end
  end

  def current_user_app_authorized?
    unless(@current_user && @current_user.superuser?)
      if (@current_user.nil? || !@current_user.app_authorized?(@current_application, @current_organization))
        redirect_to organization_view_path(:organization_id => @current_organization, :coop_app_id => CoopApp.core)
      end
    end
  end

  def current_user_app_superuser?
    unless(@current_user && @current_user.app_superuser?(@current_application))
      redirect_to organization_view_path(:organization_id => @current_organization, :coop_app_id => CoopApp.core)
    end
  end

  def current_user_app_admin?
    unless(@current_user && @current_application && @current_organization && @current_user.has_authority?(AuthorizationLevel.app_administrator(@current_application), @current_organization, :superuser => true))
      org = @current_organization.nil? ? Organization.default : @current_organization
      redirect_to organization_view_path(:organization_id => org)
    end
  end

  def user_authorize(auth_level)
    if @current_user.nil? || @current_organization.nil? || !@current_user.has_authority?(auth_level, @current_organization, :superuser=>true)
      organization = !@current_user.nil? ? @current_user.organization : Organization.default
      redirect_to organization_view_path(:organization_id => organization)
    end
  end

  def authorized?(user, organization, authorization_level)
  end

  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end

  #
  # Vanity URL
  #
  def vanity
    orgs = Organization.where('alt_short_name = ?',params[:vanity])
    if orgs.empty?
      org = Organization.default
    else
      org = orgs.first
    end
    redirect_to organization_view_path(:organization_id => org.public_id)
  end
  #
  # Surveys
  #
  def schedule_survey_app(entity, organization, subject_id, audience, type, limit, duration, notify, anon)
    if !audience.nil? && !type.nil? && !organization.tlt_survey_questions.for_audience(audience).for_type(type).active.empty?
      schedule = entity.survey_schedules.new
      schedule.organization_id = organization.id
      schedule.subject_area_id = subject_id
      schedule.schedule_start = Date.today
      schedule.schedule_end = duration.nil? ? Date.today + type.duration_default(audience).days : Date.today + duration.to_i.days
      schedule.user_id = @current_user.id
      schedule.tlt_survey_audience_id = audience.id
      schedule.tlt_survey_type_id = type.id
      schedule.is_notify = notify
      schedule.is_anon = anon
      schedule.max_responses = limit.nil? ? type.response_limit_default(audience) : limit
      schedule.survey_instruction_id = type.instruction_for(audience).nil? ? nil : type.instruction_for(audience).id
      if schedule.save
        unless type.self_survey?(audience)
          schedule.identify_takers
        end
        if schedule.is_notify
          schedule.takers.each do |taker|
            UserMailer.survey_notification(taker, schedule.is_anon, schedule.subject_line, @current_user, organization, request.host_with_port).deliver
          end
        end
      end
    end
  end

  def stop_survey(schedule)
    schedule.update_attributes(:is_active => false)
  end

  def store_survey_responses_app(schedule)
    if schedule.takers.include?(@current_user)
      if params[:question] && schedule
        params[:question].each do |question_id,value|
          question = TltSurveyQuestion.find_by_id(question_id)rescue nil
          unless question.nil?
            response = TltSurveyResponse.new
            response.organization_id = schedule.organization.id
            response.user_id = @current_user.id
            response.tlt_survey_question_id = question_id
            response.score = value.to_i
            response.comment = ""
            if params[:survey_response]
              params[:survey_response].each do |quest_id, comment|
                if question_id == quest_id
                  response.comment = comment
                end
              end
            end
            schedule.tlt_survey_responses << response
          end
        end  # question Loop
      end
      schedule.takers.delete(@current_user)
    end
    if schedule.tlt_survey_responses.collect{|r| r.user_id}.uniq.size >= schedule.max_responses
      schedule.de_activate
    end

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
        redirect_to offering_view_path(:organization_id => @current_organization, :coop_app_id => CoopApp.core)
      end
    end
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
