# Filters added to this controller apply to all controllers in the application..
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
	
  require 'authorization_requirement'
  
  include SimpleCaptcha::ControllerHelpers
  #include ExceptionNotifiable
  include AuthorizationRequirement
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '87dffe5833622057cd1d732b7e4fbcac'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  helper_method :render_to_string
  
  before_filter :instantiate_controller_and_action_names
  before_filter :clear_notice,   :except => [:edit_profile]
  
  protected
  
  def instantiate_controller_and_action_names
    @in_admin = params[:controller].match(/admin\//)
    @current_action = action_name
    @current_controller = controller_name
  end
  
  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end
  
  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default. We take special exception to session_expiry so 
  # we don't redirect them to session_expiry if that happend to be their last action
  def redirect_back_or_default(default)
    unless session[:return_to].blank?
      uri = URI.parse session[:return_to]
      return_to = ActionController::Routing::Routes.recognize_path uri.path
      return_to[:action] ==  'session_expiry' ? redirect_to(default) : redirect_to(session[:return_to])
      session[:return_to] = nil
    else
      redirect_to(default)
    end
  end
  
  # Accesses the current registrant from the session.
  def current_user
    @current_user ||= (session[:user_id] && User.find(session[:user_id]) rescue nil) || nil
  end
  
  def current_organization
    @current_organization ||= (Organization.find_by_public_id(params[:organization_id]) rescue Organization.default)
  end
  
  def current_scope
    current_organization
  end
  
  # Store the given user in the session.
  def current_user=(new_user)
    session[:user_id] = new_user.nil? ? nil : new_user.id
    @current_user = new_user
  end
  
  def clear_notice
    flash[:notice] = nil
    flash[:error] = nil    
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

  def set_classroom_favorite(user, classroom, add)
    if (user.has_favorite?(classroom) && add=="remove") || (!user.has_favorite?(classroom) && add=="add")
      toggle_classroom_favorite(user, classroom)       
    end
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
           Notifier.deliver_survey_notification(:user => taker, :anon => schedule.is_anon, :subject => schedule.subject_line, :admin => @current_user, :current_organization => organization, :fsn_host => request.host_with_port)          
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

  def update_app_settings(app, org, provider, selected, allowed, abbrev, name, provider_id)
    unless org.app_settings(app).nil?
      org.app_settings(app).update_attributes(:is_owner => provider, :is_selected => selected, :is_allowed => allowed, :alt_abbrev => abbrev, :alt_name => name, :provider_id => provider_id)
    else
      create_app_settings(app, org, provider, selected, allowed, abbrev, name, provider_id) 
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
