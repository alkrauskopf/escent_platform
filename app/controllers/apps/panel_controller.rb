class Apps::PanelController < Apps::TimeLearningController

  helper :all # include all helpers, all the time  
  layout "ctl_panel"

  before_filter :current_organization, :except => []
  before_filter :current_user, :except => []
  before_filter :ctl_allowed?, :except=>[]
  before_filter :current_user_app_authorized?, :except=>[]
  before_filter :clear_notification

  def track_session
    initialize_parameters
    @suspended = params[:suspended] == 'true' ? true : false
  end 

  def abort_session
    initialize_parameters
    @tlt_session.destroy
    redirect_to self.send(@current_application.link_path, {:user_id=> @current_user, :organization_id => @current_organization})
  end 

  def end_session
    initialize_parameters

    if @tlt_session && params[:function] == "Close"
      stop_all_tasks(@tlt_session)
      refresh_session
      resolve_session(@tlt_session)
    end
      redirect_to self.send(@current_application.link_path, {:organization_id => @current_organization})
  end 

  def stop_session_task

    initialize_parameters
    stop_task
    render :partial => "tlt_activity_tracking", :locals => {:app => @app, :tl_session => @tlt_session}, :layout=>false
  end

  def start_session_task

    initialize_parameters
    stop_task
    new_active_log = TltSessionLog.new
    new_active_log.tlt_session_id = @tlt_session.id
    new_active_log.tl_activity_type_task_id = @task.id
    new_active_log.start_time = Time.now
    new_active_log.is_active = true
    new_active_log.duration = 0 
    if new_active_log.save
     refresh_session
    end

    render :partial => "tlt_activity_tracking", :locals => {:app => @app, :tl_session => @tlt_session}, :layout=>false
  end

  def log_no_time_session_task

    initialize_parameters
    new_log = TltSessionLog.new
    new_log.tlt_session_id = @tlt_session.id
    new_log.tl_activity_type_task_id = @task.id
    new_log.start_time = Time.now
    new_log.is_active = false
    new_log.duration = 0 
    new_log.note = params[:note]
    if new_log.save
     refresh_session
    end
    render :partial => "tlt_activity_tracking", :locals => {:app => @current_application, :tl_session => @tlt_session}, :layout=>false
  end

  def update_log_note
   
    initialize_parameters
    involve_measure = AppMethodLogRating.find_by_id(params[:involve_id]) rescue nil
    if @tlt_log
      if involve_measure
       @tlt_log.involve = involve_measure.label
       @tlt_log.involve_score = involve_measure.score     
      end
      if params[:duration_min]
       @tlt_log.duration = (params[:duration_min].to_f)*60.round
      end
      @tlt_log.note = params[:note]
      @tlt_log.update_attributes params[:tl_session_log]
      refresh_session   
    end
   render :partial => "tlt_activity_log", :locals => {:tl_session => @tlt_session, :observer => true}, :layout=>false
  end

  def update_log_strategy
   
    initialize_parameters
    if @tlt_log && @tlt_session
      strategy = TlActivityTypeTask.find_by_id(params[:task_id]) rescue nil
      old_strategy_id = @tlt_log.tl_activity_type_task_id
      @tlt_log.tl_activity_type_task_id = strategy.nil? ? @tlt_log.tl_activity_type_task_id : strategy.id    
      if @tlt_log.update_attributes params[:tl_session_log]
        refresh_session 
      end
    end
   render :partial => "tlt_activity_log", :locals => {:tl_session => @tlt_session, :observer => true}, :layout=>false
  end

  def remove_log
    initialize_parameters
    unless @tlt_log.is_active
      @tlt_log.destroy
      refresh_session
    end
   render :partial => "tlt_activity_log", :locals => {:tl_session => @tlt_session, :observer => true}, :layout=>false
  end

   private

  def ctl_allowed?
    @current_application = CoopApp.ctl
    @current_provider = @current_organization.app_provider(@current_application)
    current_app_enabled_for_current_org?
  end

  def initialize_parameters
  @suspended = false

    if  params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    end

    if  params[:user_id]
      @current_user = User.find_by_public_id(params[:user_id])rescue nil
    end

    if params[:tlt_session_id]
      @tlt_session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
    end
    
    if  params[:itl_template_id]
      @itl_template = ItlTemplate.find_by_id(params[:itl_template_id]) rescue nil
    end

    if params[:tlt_task_id]
      @task = TlActivityTypeTask.find_by_id(params[:tlt_task_id]) rescue nil
    end

    if params[:tlt_log_id]
      @tlt_log = TltSessionLog.find_by_public_id(params[:tlt_log_id])
    end

    if params[:activity_id]
      @activity = TlActivityType.find_by_id(params[:activity_id]) rescue nil
    end

  end
  
  def stop_all_tasks(session)   
    session.tlt_session_logs.active.each do |log|
      unless session.is_manual
        duration =  Time.now - log.start_time
        log.update_attributes(:is_active => false, :duration => duration)
      else
        log.update_attributes(:is_active => false)
      end
    end  
  end

  def stop_task
     current_active_logs = @current_organization.itl_org_option.is_concurrent ? @tlt_session.tlt_session_logs.active.select{|l| l.tl_activity_type_task.tl_activity_type == @activity} : @tlt_session.tlt_session_logs.active rescue []
# should only be one
  current_active_logs.each do |log|
      unless @tlt_session.is_manual
        duration =  Time.now - log.start_time
        log.update_attributes(:is_active => false, :duration => duration)
      else
        log.update_attributes(:is_active => false)
      end
    end
    refresh_session 
  end 

  def refresh_session
    @tlt_session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
  end

  def resolve_session(session)
    if session.tlt_session_logs.size == 0 
      session.destroy
    else
       close_session(session)
    end    
  end

  def close_session(session)
    belt_id = ItlBeltRank.none.first.id rescue 99
    if @current_organization.itl_belt_ranking?
      unless @current_user.itl_belt_rank 
        white_belt = ItlBeltRank.white
        message = session.is_training ? 'Initiated By First Practice Observation' : 'Initiated By First Observation'
        create_belt_for(@current_user, ItlBeltRank.white.id, message, @current_user)
        belt_id = ItlBeltRank.white.id
      else
        belt_id = @current_user.itl_belt_rank.id
      end
    end
    session.update_attributes(:logs_are_closed => true, :session_length => session.session_duration(Time.now), :itl_belt_rank_id => belt_id)
    unless session.training?
      audience = @current_application.tlt_survey_audiences.observer.first
      type = @current_application.tlt_survey_types.observation.first
      schedule_survey_app(session, @current_organization, session.subject_area_id, audience, type, nil, nil, type.notify_default(audience), type.anon_default(audience))
      audience = @current_application.tlt_survey_audiences.teacher.first
      schedule_survey_app(session, @current_organization, session.subject_area_id, audience, type, nil, nil, type.notify_default(audience), type.anon_default(audience))
    end
  end

end
