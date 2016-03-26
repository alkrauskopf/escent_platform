class Apps::TimeLearningController < Site::ApplicationController
  helper :all # include all helpers, all the time  
 layout "tlt", :except =>[:log_summary, :activity_summary, :show_template, :show_not_timed_tasks, :owner_show_video_session,
                          :manage_template, :create_training_video, :manage_belt_user, :manage_belt_rankings,
                          :training_classroom, :observation_subject_list, :list_backlog_for, :observation_panel_help,
                          :then_now, :send_invite, :research_summary, :subject_tlt_sessions,:add_survey_question,
                          :take_survey, :teacher_itl_dashboards, :diagnostic_history, :diagnostics, :student_feedback,
                          :population_stats, :school_utilization, :school_type_utilization, :subject_dashboard]

  before_filter :current_organization, :except => []
  before_filter :current_user, :except => []
  before_filter :ctl_allowed?, :except=>[]
  before_filter :current_user_app_authorized?, :except=>[]
 before_filter :clear_notification, :except =>[:teacher_private_itl_dashboards]
  
 def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end
  



  def index

    initialize_parameters
    CoopApp.ctl.increment_views
    itl_groupings

    clean_unresolved_observer_sessions

  end

  def list_backlog_for

    initialize_parameters

  end

  def observation_subject_list

    initialize_parameters

  end

 
   def setup_session

    initialize_parameters

    @practice = params[:practice] ? true:false
    @video_list = @practice ? @current_organization.coop_app_resources.for_app(@app).collect{|app_res| app_res.content}.select{|c| c.embed_code?} : []
    @video_list.each do|vid|
      vid.title = vid.irr_resource? ? "** " + vid.title : vid.title
    end
    !@video_list.sort{|a,b| b.title<=> a.title}
    
    if params[:function] == "Track"
      @tlt_session = TltSession.new
      @tlt_session.classroom_id = @classroom.id
      @tlt_session.classroom_period_id = @period.id
      @tlt_session.user_id = @practice ? @current_user.id : @teacher.id
      @tlt_session.tracker_id = @current_user.id
      @tlt_session.organization_id = @current_organization.id
      @tlt_session.subject_area_id = @classroom.subject_area.parent_id ? @classroom.subject_area.parent_id : @classroom.subject_area.id  
      @tlt_session.is_observer_done = false
      @tlt_session.is_teacher_done = false
      @tlt_session.is_training = @practice
      @tlt_session.teacher_done_date = Date.today
      @tlt_session.is_final = false
      @tlt_session.topic_id = params[:tlt_session][:topic_id]
      @tlt_session.content_id = params[:tlt_session][:content_id] ? params[:tlt_session][:content_id]: nil
      @tlt_session.lesson = params[:tlt_session][:lesson]
      @tlt_session.students = params[:tlt_session][:students]=="" ? 0 : params[:tlt_session][:students]
      @tlt_session.observations = params[:tlt_session][:observations]
      @tlt_session.duration = params[:tlt_session][:duration].to_i.nil? ? 60: (params[:tlt_session][:duration].to_f * 60.0).round
      @tlt_session.learning = ""
      @tlt_session.next_step = ""
      @tlt_session.teacher_remark = ""
      @tlt_session.classroom_name = @classroom.course_name
      @tlt_session.class_period_name = @period.name      
      belt_id = ItlBeltRank.none.first.id rescue 99
      if @current_organization.itl_belt_ranking?
        unless @current_user.itl_belt_rank 
          message = @tlt_session.is_training ? "Initiated By First Practice Observation" : "Initiated By First Observation"
          create_belt_for(@current_user, ItlBeltRank.white.id, message, @current_user)
          belt_id = ItlBeltRank.white.id
        else
          belt_id = @current_user.itl_belt_rank.id
        end
      end
      @tlt_session.itl_belt_rank_id = belt_id
      if !params[:coop_app]
        @tlt_session.itl_template = @current_organization.useable_itl_templates.first rescue nil
       elsif params[:coop_app][:meth] == ""
        @tlt_session.itl_template = @current_organization.useable_default_template 
       else 
        @tlt_session.itl_template = ItlTemplate.find_by_id(params[:coop_app][:meth].to_i)   
      end  
      if @tlt_session.itl_template 
        @tlt_session.app_methods << @tlt_session.itl_template.app_methods
      end
      if params[:commit] == "Enter Past Session"
        @tlt_session.is_manual = true
        if params[:session_date] 
          @tlt_session.session_date = params[:session_date]
        else
           @tlt_session.session_date = Date.today
        end
         
        unless params[:tlt_session][:tracker_id] == ""
          @tlt_session.tracker_id = params[:tlt_session][:tracker_id]
        end
      else
        @tlt_session.is_manual = false
        @tlt_session.session_date = Date.today
      end
      if @tlt_session.save
        if @tlt_session.content && @tlt_session.content.embed_code?
          if @tlt_session.tlt_session_video
            @tlt_session.tlt_session_video.update_attributes(:embed_code => @tlt_session.content.content_object)
          else 
            video = TltSessionVideo.new
            video.embed_code = @tlt_session.content.content_object
            @tlt_session.tlt_session_video = video
          end
        end
#        redirect_to :action => 'track_session', :organization_id => @current_organization, :tlt_session_id => @tlt_session
        redirect_to :controller => 'apps/panel', :action => 'track_session', :user_id=> @current_user, :organization_id => @current_organization, :tlt_session_id => @tlt_session, :suspended => false
      else
        flash[:error] = @tlt_session.errors.full_messages.to_sentence 
      end
    end   
   end

  def show_not_timed_tasks

    initialize_parameters
    @app_method = AppMethod.find_by_id(params[:app_method_id])
    @itl_template = ItlTemplate.find_by_id(params[:itl_template_id]) rescue nil

  end

  def training_classroom

    initialize_parameters

  end

  def define_training_room

    initialize_parameters

    if params[:classroom_period_id]
      @current_organization.itl_org_option.update_attributes(:classroom_period_id => params[:classroom_period_id])
    else
      @current_organization.itl_org_option.update_attributes(:classroom_period_id => nil)
    end
    
    render :partial => "/apps/time_learning/manage_options_training", :locals => {:app=>@app}
  end


  def subject_tlt_sessions
    initialize_parameters
    @tab = params[:tab]
    tab_id=""
    backlog = "open"
    pending = "pending"
    finalized = "finalized"
    practice = "practice"
    @group = params[:group] rescue ""
    @sessions = []
    begin_day = DateTime.parse(params[:session_month]) rescue nil
    if params[:destroy_session]      
      destroy_session = TltSession.find_by_public_id(params[:destroy_session]) rescue nil
      if destroy_session 
        begin_day = destroy_session.session_date.at_beginning_of_month
        @tlt_subject = destroy_session.subject_area
        destroy_session.destroy
      end 
    end
    if @group == "subject"
       if @tab == finalized
         @sessions = @current_organization.tlt_sessions.for_subject(@tlt_subject).final.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == backlog
         @sessions = @current_organization.tlt_sessions.for_subject(@tlt_subject).backlog.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == pending
         @sessions = @current_organization.tlt_sessions.for_subject(@tlt_subject).backlog.not_practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       else
         @sessions = @current_organization.tlt_sessions.for_subject(@tlt_subject).practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       end  
       tab_id = @tlt_subject.id.to_s
    end
    if @group == "teacher"
       if @tab == finalized
         @sessions = @current_organization.tlt_sessions.for_teacher(@user).final.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == backlog
         @sessions = @current_organization.tlt_sessions.for_teacher(@user).backlog.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == pending
         @sessions = @current_organization.tlt_sessions.for_teacher(@user).backlog.not_practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       else
         @sessions = @current_organization.tlt_sessions.for_teacher(@user).practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       end 
       tab_id = @user.id.to_s
    end   
    if @group == "observer"
       if @tab == finalized
         @sessions = @current_organization.tlt_sessions.for_observer(@user).final.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == backlog
         @sessions = @current_organization.tlt_sessions.for_observer(@user).backlog.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == pending
         @sessions = @current_organization.tlt_sessions.for_observer(@user).backlog.not_practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       else
         @sessions = @current_organization.tlt_sessions.for_observer(@user).practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       end
       tab_id = @user.id.to_s
    end
    if @group == "month"
       tab_id = begin_day.strftime("%Y-%m")
       if @tab == finalized
         @sessions = @current_organization.tlt_sessions.between_dates(begin_day, begin_day.at_end_of_month).final.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == backlog
         @sessions = @current_organization.tlt_sessions.between_dates(begin_day, begin_day.at_end_of_month).backlog.completed.sort{|a,b| b.session_date <=> a.session_date}
       elsif @tab == pending
         @sessions = @current_organization.tlt_sessions.between_dates(begin_day, begin_day.at_end_of_month).backlog.not_practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       else
         @sessions = @current_organization.tlt_sessions.between_dates(begin_day, begin_day.at_end_of_month).practice.completed.sort{|a,b| b.session_date <=> a.session_date}
       end
    end
  render :partial => "/apps/time_learning/list_sessions", :locals => {:admin => @admin, :group=> @group, :sessions=>@sessions, :user => @user, :tab=> @tab, :tab_id=>tab_id, :app_methods=> @sessions.collect{|s| s.app_methods}.flatten.uniq.sort_by{|a| a.position}, :app => @app}
  end
  
  def send_invite
    initialize_parameters
    sender = User.find_by_public_id(params[:sender]) rescue @current_user   
    recipient = User.find_by_public_id(params[:recipient]) rescue @current_user
    if sender && recipient
       Notifier.deliver_observation_invite(:user => recipient, :sender => @current_user, :arrange => params[:arrangement], :message=>params[:invite_text], :fsn_host => request.host_with_port)          
      flash[:notice]  = "Invitation Sent To " + recipient.first_name
    else
      flash[:error]  = "Invitation Failed"
    end
    render :partial => "observation_invite", :locals => {:group => params[:group], :sender => sender, :recipient => recipient}

  end

  def toggle_practice_video
    initialize_parameters
    show = params[:vid_show] == "On" ? true : false
    content = Content.find_by_public_id(params[:video_stream]) rescue nil
    render :partial => "track_session_header", :locals => {:session => @tlt_session, :show_video => show, :stream => content}
  end

  def teacher_itl_dashboards
    initialize_parameters
  end

  def teacher_private_itl_dashboards
    initialize_parameters
    @audience = CoopApp.itl.tlt_survey_audiences.teacher.first
    @survey_type = CoopApp.itl.tlt_survey_types.reflective.first
    @last_session = @current_user.tlt_sessions.for_subject(@subject_area).last rescue nil
    @since = Date.today - @current_organization.itl_org_option.stat_window.weeks 
  end

  def population_stats
    initialize_parameters
    @since = Date.today - @current_organization.itl_org_option.stat_window.weeks 
  end


  def school_utilization
    initialize_parameters
  end

  def school_type_utilization
    initialize_parameters
    @school_type = OrganizationType.find_by_id(params[:org_type_id]) rescue nil
  end

  def compare_school
    initialize_parameters
    compare = Organization.find_by_id(params[:compare_id]) rescue @school 
    render :partial => "/apps/time_learning/school_itl_dashboard", :locals => {:school => @school, :app => @app, :compare => compare}
  end

  def subject_dashboard
    initialize_parameters
  end


  def session_history
    initialize_parameters
    itl_groupings
    render :partial => "/apps/time_learning/manage_tlt_sessions", :locals => {:admin => @admin, :group => params[:grouping], :tab=>params[:tab], :app => @app}
  end

  def take_survey
    initialize_parameters
    
    if params[:function] == "submit"
        store_survey_responses_app(@schedule)
        redirect_to :action => 'static_itl_session', :organization_id => @current_organization, :tlt_session_id => @tlt_session
    end
  end
 
  def take_tlt_survey
    initialize_parameters
    
    if params[:function] == "submit"
      if @tlt_session.tlt_survey_responses.for_audience(@audience).for_user(@current_user).size == 0

        store_survey_responses(@tlt_session)

      end # end of Check if Survey Already Taken
    redirect_to :controller => "/site/site",:action => :static_classroom, :organization_id => @current_organization,  :id => @classroom 
    end
  end

  def attach_embed_code
   
    initialize_parameters

    embed = params[:embed_code].gsub(/width="\d+/, 'width="500').gsub(/height="\d+/, 'height="405')
    unless @tlt_session.tlt_session_video
        video = TltSessionVideo.new
        video.embed_code = embed
        @tlt_session.tlt_session_video = video
    else
    @tlt_session.tlt_session_video.update_attributes(:embed_code => embed)
    end
    refresh_session
    render :partial => "video_attach", :locals => {:session => @tlt_session, :teacher=> teacher_update?(@tlt_session), :observer => observer_update?(@tlt_session)}
  end

  def remove_embed_code
   
    initialize_parameters

    if @tlt_session.tlt_session_video
      @tlt_session.tlt_session_video.delete
      refresh_session
    end
   render :partial => "video_attach", :locals => {:session => @tlt_session, :teacher=> teacher_update?(@tlt_session), :observer => observer_update?(@tlt_session)}
  end

  def video_show
    if request.xhr?
      @content = Content.find_by_public_id(params[:id])
      # respond_to do |wants|
      #   wants.html { render :template => "/admin/content/show" } 
      # end  
    end
  end

  def add_video_to_rl
    initialize_parameters    
    if @tlt_session && @tlt_session.tlt_session_video && !@tlt_session.tlt_session_video.embed_code.empty?

      video = Content.new
      video.user = @current_user
      video.organization = @current_organization
      video.subject_area = SubjectArea.pd.first      
      video.subject_area_old = SubjectArea.pd.first.name
      video.content_status = ContentStatus.find_by_name("Available")
      video.title = @app.abbrev + " Observation: " + @tlt_session.classroom_name + ", "+ @tlt_session.organization.medium_name   
      video.description = @tlt_session.session_date.strftime("%b %d, %Y") + " observation of " +  @tlt_session.user.full_name + " by observer " + @tlt_session.tracker.full_name + ". The " + @tlt_session.organization.short_name + " " + @tlt_session.classroom_name + " class was observed for " +  (@tlt_session.session_length/60).round.to_s + " minutes"
      video.publish_start_date = Time.now
      video.publish_end_date = Time.now.advance(:years=>20)
      video.content_object = @tlt_session.tlt_session_video.embed_code
      video.content_object_type = ContentObjectType.find_by_content_object_type("HTML")
      video.content_upload_source = ContentUploadSource.ctl.first        
      video.terms_of_service = true
      video.is_delete = false
      video.caption = ""
      video.source_url=""
      video.source_name=""
      video.content_resource_type= ContentResourceType.ctl.first     
      video.resource_type = ContentResourceType.ctl.first.name
      video.target_score_range = "-na-"
      video.act_subject_id = @tlt_session.subject_area.act_subject_id
      if video.save       
        @tlt_session.update_attributes(:content_id => @current_user.contents.last.id)
      end

    end
    refresh_session
    render :partial => "video_attach", :locals => {:session => @tlt_session, :teacher=> teacher_update?(@tlt_session), :observer => observer_update?(@tlt_session)}

  end


  def create_training_video
    initialize_parameters
  end

  def observation_panel_help
   
    initialize_parameters

  end

  def send_student_survey
   
    initialize_parameters

    if @tlt_session && @tlt_session.student_survey.nil? && !@tlt_session.student_survey_expired?
      student_itl_survey(@tlt_session)   
    end
    render :partial => "list_hat_backlog", :locals => {:admin => @admin, :hat=> @hat, :user => @current_user, :app => @app}
  end

  def send_student_survey_from_static_page
    initialize_parameters
    if @tlt_session && @tlt_session.student_survey.nil? && !@tlt_session.student_survey_expired?
      student_itl_survey(@tlt_session)   
    end
    render :partial => "itl_session_student_survey", :locals => {:session => @tlt_session}
  end

 def static_itl_session
    initialize_parameters

    @observer_full_name = @tlt_session.tracker.nil? ? "Former User" : @tlt_session.tracker.full_name
    @observer_last_name = @tlt_session.tracker.nil? ? "Former User" : @tlt_session.tracker.last_name  
    @observer_update = observer_update?(@tlt_session)
    @teacher_full_name = @tlt_session.user.nil? ? "Former User" : @tlt_session.user.full_name
    @teacher_last_name = @tlt_session.user.nil? ? "Former User" : @tlt_session.user.last_name
    @teacher_update = teacher_update?(@tlt_session)
    obsrvr = @app.tlt_survey_audiences.observer.first
    post_conf = @app.tlt_survey_types.post_conference.first
    @survey = @observer_update && !@tlt_session.survey_schedules.for_type(post_conf).for_audience(obsrvr).active.empty? ? @tlt_session.survey_schedules.for_type(post_conf).for_audience(obsrvr).active.first : nil
 end 

  def edit_session_comments
    initialize_parameters    
    observations = (params[:pre_conf]=="undefined" || !params[:pre_conf]) ? @tlt_session.observations : params[:pre_conf]
    teacher_remark = (params[:teacher_note]=="undefined" || !params[:teacher_note]) ? @tlt_session.teacher_remark : params[:teacher_note]
    learning = (params[:observer_note]=="undefined" || !params[:observer_note]) ? @tlt_session.learning : params[:observer_note]
    next_step = (params[:next_step]=="undefined" || !params[:next_step]) ? @tlt_session.next_step : params[:next_step]    
    
    if @tlt_session.update_attributes(:observations=> observations, :teacher_remark=>teacher_remark, :learning=>learning, :next_step=>next_step) 
      flash[:notice] = "Notes Updated"
    else
      flash[:error] = "Notes Not Updated"      
    end
    render :partial => "itl_session_notes", :locals => {:session => @tlt_session, :observer =>  observer_update?(@tlt_session), :teacher => teacher_update?(@tlt_session)}
  end 

  def refresh_activity_summary
    initialize_parameters
    render :partial => "itl_activity_summary", :locals => {:session => @tlt_session, :update=> params[:update] } 

  end 
  
  def activity_summary
    initialize_parameters
    @level = params[:level]
    @observer_update = params[:update]
  end    

  def log_summary
    initialize_parameters
    @observer_update = params[:update]
  end


  def research_summary
    initialize_parameters
    research_views
    color_palette
    @irr = params[:irr]
    @session = TltSession.find_by_public_id(params[:session_id]) rescue nil
    @task = []
    @header=[]

    if params[:display_type]=="a"
      @header[0] = "%"
      @header[1] = @res_views[0][0]
      @header[2] = 100
      row_idx = 0
      @session.logs_for_method(AppMethod.rs.first).collect{|l| l.tl_activity_type_task}.uniq.each do |task|
        duration = @session.tlt_session_logs.for_task(task).collect{ |l| l.duration}.sum 
        involvement = @session.student_involvement_for_task(task) rescue nil
        column_count = ((50.0*duration.to_f/@session.session_length.to_f)+0.5).round 
        stat = (100*duration.to_f/@session.session_length.to_f).round.to_i
        warning = []
        if @current_organization.itl_thresholds? && task.itl_strategy_threshold
          if (!task.itl_strategy_threshold.min_pct.nil? && task.itl_strategy_threshold.min_pct > stat)
            warning[0] = stat.to_s + "% May Be A Bit Low"
            warning[1] =  task.itl_strategy_threshold.min_pct_msg
          elsif (!task.itl_strategy_threshold.max_pct.nil? && task.itl_strategy_threshold.max_pct < stat)
            warning[0] = stat.to_s + "% May Be A Bit High"
            warning[1] =  task.itl_strategy_threshold.max_pct_msg
          end
        end
        @task[row_idx]= [task.name, stat.to_s + "%", column_count, research_color(task.research), involvement_color(involvement), duration, involvement, warning[0], warning[1], @session.id.to_s + params[:display_type]]
        row_idx += 1
      end
    @task.sort!{|a,b| b[5]<=> a[5]}
    end

    if params[:display_type]=="b"
      @header[0] = "Min"
      @header[1] = @res_views[1][0]
      @header[2] = ((@session.tlt_session_logs.collect{|l| l.duration}.max.to_f/60.0).ceil*1.1).ceil
      @session.logs_for_method(AppMethod.rs.first).each_with_index do |log, row_idx|
          involvement = log.involve_score
          column_count = ((50.0*log.duration.to_f/(@header[2]*60).to_f)).round 
          stat = (log.duration.to_f/60.0).round(1)
          warning = []
          if @current_organization.itl_thresholds? && log.tl_activity_type_task.itl_strategy_threshold
            if (!log.tl_activity_type_task.itl_strategy_threshold.min_minutes.nil? && log.tl_activity_type_task.itl_strategy_threshold.min_minutes > stat)
              warning[0] = stat== 1.0 ? (stat.to_s + " Minute May Be A Bit Low") : (stat.to_s + " Minutes May Be A Bit Low")
              warning[1] =  log.tl_activity_type_task.itl_strategy_threshold.min_minutes_msg
            elsif (!log.tl_activity_type_task.itl_strategy_threshold.max_minutes.nil? && log.tl_activity_type_task.itl_strategy_threshold.max_minutes < stat)
              warning[0] = stat== 1.0 ? (stat.to_s + " Minute May Be A Bit High") : (stat.to_s + " Minutes May Be A Bit High")
              warning[1] =  log.tl_activity_type_task.itl_strategy_threshold.max_minutes_msg
            end
          end
          @task[row_idx]= [log.tl_activity_type_task.name, stat, column_count, research_color(log.tl_activity_type_task.research), involvement_color(involvement), log.duration, involvement, warning[0], warning[1],@session.id.to_s + params[:display_type]]
          row_idx += 1
      end
    end
  end 
  
  def then_now
    initialize_parameters
    research_views
    color_palette
    @belt = params[:belt_id] ? ItlBeltRank.find_by_id(params[:belt_id]) : ItlBeltRank.none.first
    @then_now_type = params[:type]
    if @then_now_type == "teacher"
      @l_entity = User.find_by_id(params[:l_entity]) rescue @teacher
      l_header = @l_entity.last_name
      if params[:new_r_entity] == "T"
        @r_entity = @l_entity
        @r_entity_select = [@r_entity.last_name, "T"]
       elsif params[:new_r_entity].to_i > 0
          @r_entity = Organization.find_by_id(params[:new_r_entity]) 
          @r_entity_select = [@r_entity.medium_name, @r_entity.id]
        else
          @r_entity = @current_organization
          @r_entity_select = ["All " + @r_entity.organization_type.name.pluralize , "P"]
        end
      r_header = @r_entity_select[0]       
      @subject_list = @l_entity.tlt_sessions.collect{|s| s.subject_area}.uniq.sort_by{|s| s.name}
    elsif @then_now_type == "org"
      @l_entity = Organization.find_by_id(params[:l_entity]) rescue @current_organization
      l_header = @l_entity.medium_name
      @r_entity = params[:new_r_entity].to_i > 0 ? Organization.find_by_id(params[:new_r_entity]): @current_organization 
      @r_entity_select = params[:new_r_entity] == "P" ? ["All " + @r_entity.organization_type.name.pluralize , "P"] : [@r_entity.medium_name, @r_entity.id]
      r_header = @r_entity_select[0]
      @subject_list = SubjectArea.all_parents
    else
      l_header = "No Left Entity"
      r_header = "No Right Entity"
    end
    @subject = SubjectArea.find_by_id(params[:new_subject]) rescue nil        
    @strategy_table = []
    @category_table = []
    @time_table = []
    @session_count = []
    @header = [] 
       
    unless params[:t_start_y] && params[:t_start_m] 
      @time_table[0] = @l_entity.tlt_sessions.final.empty? ? Date.today : @l_entity.tlt_sessions.final.first.session_date
      else
      @time_table[0] = Date.new(params[:t_start_y].to_i, params[:t_start_m].to_i, 1)
    end
    unless params[:t_end_y] && params[:t_end_m]
      @time_table[1] = @l_entity.tlt_sessions.final.empty? ? Date.today.end_of_month : @l_entity.tlt_sessions.final.last.session_date.end_of_month
      else
      @time_table[1] = Date.new(params[:t_end_y].to_i, params[:t_end_m].to_i, 1).end_of_month
    end
    unless params[:n_start_y] && params[:n_start_m]
      @time_table[2] = @r_entity.tlt_sessions.final.empty? ? Date.today : @r_entity.tlt_sessions.final.first.session_date
      else
      @time_table[2] = Date.new(params[:n_start_y].to_i, params[:n_start_m].to_i, 1)
    end
    unless params[:n_end_y] && params[:n_end_m]
      @time_table[3] = @r_entity.tlt_sessions.final.empty? ? Date.today.end_of_month : @r_entity.tlt_sessions.final.last.session_date.end_of_month
      else
      @time_table[3] = Date.new(params[:n_end_y].to_i, params[:n_end_m].to_i, 1).end_of_month
    end
    @time_table[1] = @time_table[1] < @time_table[0] ? @time_table[0] : @time_table[1]
    @time_table[3] = @time_table[3] < @time_table[2] ? @time_table[2] : @time_table[3]
    @subject_select = @subject ? [@subject.name, @subject.id] :["All Subjects", "A"]
    @header[0] = [l_header, @subject_select[0], r_header ]         

    @l_entity.class.to_s == "User" ? user_logs_strategies(@l_entity, @subject,@time_table[0],@time_table[1], @belt ):summary_logs_strategies(@l_entity, @subject,@time_table[0],@time_table[1],false, @belt)
    left_logs = @logs
    left_strategies = @strats
    @session_count[0] = @sess_count
    @r_entity.class.to_s == "User" ? user_logs_strategies(@r_entity, @subject,@time_table[2],@time_table[3], @belt ):summary_logs_strategies(@r_entity, @subject,@time_table[2],@time_table[3],params[:new_r_entity]=="P", @belt)
    right_logs = @logs
    right_strategies = @strats
    @session_count[1] = @sess_count
 
    strategies = (left_strategies + right_strategies).uniq

    left_total_duration = left_logs.empty? ? 0 : left_logs.collect{ |l| l.duration}.compact.sum 
    right_total_duration = right_logs.empty? ? 0 : right_logs.collect{ |l| l.duration}.compact.sum

      AppMethod.rs.first.tl_activity_types.each_with_index do |cat,idx|

        left_cat_duration = left_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.duration}.sum rescue 0
        right_cat_duration = right_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.duration}.sum rescue 0

        left_cat_pct_duration = left_total_duration == 0 ? 0 : (100.0*left_cat_duration.to_f/left_total_duration.to_f).round
        right_cat_pct_duration = right_total_duration == 0 ? 0 : (100.0*right_cat_duration.to_f/right_total_duration.to_f).round

        unless left_logs.empty?
          if left_logs[0].class.to_s == "TltSessionLog"
            left_cat_involvements =  left_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.involve_score}.compact rescue[]
            left_cat_avg_involvement = left_cat_involvements.size == 0 ? nil : left_cat_involvements.sum/left_cat_involvements.size
          else
            left_cat_segments = left_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.engage_segments}.sum rescue 0
            left_cat_engage = left_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.engage_total}.sum rescue 0
            left_cat_avg_involvement = left_cat_segments == 0 ? nil : left_cat_engage/left_cat_segments
          end
        else
          left_cat_avg_involvement = nil
        end
        unless right_logs.empty?
          if right_logs[0].class.to_s == "TltSessionLog"
            right_cat_involvements =  right_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.involve_score}.compact rescue[]
            right_cat_avg_involvement = right_cat_involvements.size == 0 ? nil : right_cat_involvements.sum/right_cat_involvements.size
          else
            right_cat_segments = right_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.engage_segments}.sum rescue 0
            right_cat_engage = right_logs.select{|l| l.tl_activity_type_task.tl_activity_type_id == cat.id}.collect{ |l| l.engage_total}.sum rescue 0
            right_cat_avg_involvement = right_cat_segments == 0 ? nil : right_cat_engage/right_cat_segments
          end
        else
          right_cat_avg_involvement = nil
        end          
        left_cat_col_count = (30.0*left_cat_pct_duration.to_f/100.0).ceil
        right_cat_col_count = (30.0*right_cat_pct_duration.to_f/100.0).ceil

        @category_table[idx]= [cat.activity, left_cat_pct_duration, right_cat_pct_duration, left_cat_col_count, right_cat_col_count, "#f0f9fb", involvement_color(left_cat_avg_involvement), involvement_color(right_cat_avg_involvement)]

      end
      
      strategies.each_with_index do |strat,idx|
        left_strat_duration = left_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.duration}.sum rescue 0
        right_strat_duration = right_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.duration}.sum rescue 0

        left_pct_duration = left_total_duration == 0 ? 0 : (100.0*left_strat_duration.to_f/left_total_duration.to_f).round
        right_pct_duration = right_total_duration == 0 ? 0 : (100.0*right_strat_duration.to_f/right_total_duration.to_f).round

        unless left_logs.empty?
          if left_logs[0].class.to_s == "TltSessionLog"
            left_strat_involvements = left_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.involve_score}.compact rescue []
            left_avg_involvement = left_strat_involvements.size == 0 ? nil : left_strat_involvements.sum/left_strat_involvements.size
          else
            left_segments = left_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.engage_segments}.sum rescue 0
            left_engage = left_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.engage_total}.sum rescue 0
            left_avg_involvement = left_segments == 0 ? nil : left_engage/left_segments
          end
        else
          left_avg_involvement = nil
        end
        unless right_logs.empty?
          if right_logs[0].class.to_s == "TltSessionLog"
            right_strat_involvements = right_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.involve_score}.compact rescue []
            right_avg_involvement = right_strat_involvements.size == 0 ? nil : right_strat_involvements.sum/right_strat_involvements.size
          else
            right_segments = right_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.engage_segments}.sum rescue 0
            right_engage = right_logs.select{|l| l.tl_activity_type_task_id == strat.id}.collect{ |l| l.engage_total}.sum rescue 0
            right_avg_involvement = right_segments == 0 ? nil : right_engage/right_segments
          end
        else
          right_avg_involvement = nil
        end

        left_col_count = (30.0*left_pct_duration.to_f/100.0).ceil
        right_col_count = (30.0*right_pct_duration.to_f/100.0).ceil

        @strategy_table[idx]= [strat.name, left_pct_duration, right_pct_duration, left_col_count, right_col_count, research_color(strat.research), involvement_color(left_avg_involvement), involvement_color(right_avg_involvement)]
      end
      @strategy_table.sort!{|a,b| b[3]<=> a[3]}

  end

  def survey_comments
    initialize_parameters
  end 
   
  def finalize_session
    initialize_parameters
    if params[:function] == "observer" && !@tlt_session.is_final
      if @tlt_session.update_attributes(:is_observer_done => true, :is_teacher_done => true, :is_final => true, :finalize_date => Date.today, :observer_done_date => Date.today, :teacher_done_date => Date.today)
        update_dashboard(@tlt_session)
        create_summary_data(@tlt_session)
      end
    end
    if params[:function] == "teacher"
      final = @tlt_session.is_observer_done ? true : false
      final_date = final ? Date.today : nil
      if (final && @tlt_session.update_attributes(:is_teacher_done => true, :is_final => final, :finalize_date => final_date, :teacher_done_date => Date.today)) 
        update_dashboard(@tlt_session)
        create_summary_data(@tlt_session) 
      end
    end
    redirect_to :action => 'static_itl_session', :organization_id => @current_organization, :tlt_session_id => @tlt_session
  end 
  
  def recalc_itl_summary
    initialize_parameters
    summary = ItlSummary.find_by_public_id(params[:summary_id]) rescue nil
    if (summary && summary.organization && summary.subject_area && summary.classroom && summary.itl_belt_rank)
      summary.destroy
      summary.itl_sessions.each do |session|
        create_summary_data(session)
      end      
    end
    render :partial => "/apps/owner_maintenance/app_ctl_school_subject_dashboards", :locals => {:app => @app, :school=>summary.organization, :subject=>summary.subject_area}
   end  

  def add_survey_question
    initialize_parameters

    unless params[:question].empty?
      @question = TltSurveyQuestion.new
      @question.organization_id = @current_organization.id
      @question.user_id = @current_user.id
      @question.tlt_survey_audience_id = @audience.nil? ? @app.tlt_survey_audiences.first.id : @audience.id
      @question.tlt_survey_type_id = @survey_type.nil? ? TltSurveyType.first.id : @survey_type.id
      @question.question = params[:question]
      @question.tlt_survey_range_type_id = params[:range_type_id].empty? ? 1 : params[:range_type_id]   
      @question.is_active = true
      @question.coop_app_id = @app.id
      @question.save
    end
   render :partial => "/apps/shared/sumarize_surveys", :locals => {:admin => @admin, :org => @current_organization, :app => @app} 
 end

  def diagnostics

    initialize_parameters
    @diagnostic_complete = false
    if params[:function] == "submit"
      diagnostic = TltDiagnostic.new
      diagnostic.user_id = @current_user.id
      diagnostic.organization_id = @current_organization.id
      diagnostic.subject_area_id = @subject_area.id
      diagnostic.save
      if @current_user.tlt_diagnostics.last
        params[:strategy].each do |s_activity_id,s_value|
          params[:effective].each do |e_activity_id, e_value|
            if s_activity_id == e_activity_id
              unless s_value == "" && e_value == ""
                lesson = TltDiagnosticLesson.new
                lesson.tlt_diagnostic_id = @current_user.tlt_diagnostics.last.id
                lesson.tl_activity_type_id = s_activity_id.to_i
                lesson.strategies = s_value
                lesson.how_effective = e_value
                lesson.save
              end
            end
          end
        end
        @diagnostic_complete = true
        flash[:notice] = "Analysis Saved" 
        if @current_user.tlt_diagnostics.last.survey_schedules.empty?
          audience = @app.tlt_survey_audiences.teacher.first
          type = @app.tlt_survey_types.reflective.first
          schedule_survey_app(@current_user.tlt_diagnostics.last, @current_organization, diagnostic.subject_area_id, audience, type, nil, nil, type.notify_default(audience), type.anon_default(audience))
        end
        store_survey_responses_app(@current_user.tlt_diagnostics.last.survey_schedules.last)
      end  # diagnostic Save Condition
      redirect_to :action => :teacher_private_itl_dashboards, :organization_id => @current_organization,  :subject_area_id => @subject_area, :teacher_id => @current_user
    end # end of Check Submission

    @audience = CoopApp.itl.tlt_survey_audiences.teacher.first
    @survey_type = CoopApp.itl.tlt_survey_types.reflective.first
    @last_session = @current_user.tlt_sessions.for_subject(@subject_area).last rescue nil
  end

  def diagnostic_history

    initialize_parameters

  end

  def student_feedback

    initialize_parameters

    @audience = @app.tlt_survey_audiences.student.first

  end

  def take_post_conf_survey
    initialize_parameters        
    if params[:function] == "submit"
      if @tlt_session.tlt_survey_responses.empty?
        store_survey_responses_app(@schedule)
      end 
    end
    redirect_to :action => 'finalize_session', :organization_id => @current_organization, :user_id => @current_user, :tlt_session_id => @tlt_session, :function => "observer"
  end


  def edit_option_window
    initialize_parameters

    if @current_organization.itl_org_option.update_attributes(:stat_window =>params[:window])
      flash[:notice] = "Statistics Window Updated Successfully"       
    else
       flash[:error] = @current_organization.itl_org_option.errors.full_messages.to_sentence 
    end
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}  
  end

  def edit_schedule_url
    initialize_parameters
    label = params[:schedule_url]== '' || params[:schedule_label]== '' ? params[:schedule_url]: params[:schedule_label]

    if @current_organization.itl_org_option.update_attributes(:schedule_url =>params[:schedule_url], :schedule_label => label)
      flash[:notice] = "Scheduling Resource Link Updated"       
    else
       flash[:error] = @current_organization.itl_org_option.errors.full_messages.to_sentence 
    end
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}  
  end

  def toggle_school_dashboard_details
    initialize_parameters
    activity = TlActivityType.find_by_id(params[:activity_id])
    toggle = params[:task_details].to_i == 1 ? true:false  
    columns = params[:columns]
    start_date = DateTime.parse(params[:start_date] || Time.now.strftime("%Y-%m-%d")).strftime("%Y-%m-%d")
    tl_sessions=[]
    duration=[]
    subj=[]
    idx = 0
    until idx == columns.size
      columns[idx] = columns[idx].to_i
      tl_sessions[idx] = params[:tl_sessions][idx].to_i
      duration[idx] = params[:duration][idx].to_f     
      subj[idx] = SubjectArea.find_by_public_id(params[:subj][idx]) rescue nil
      idx += 1
    end
    render :partial => "/apps/time_learning/school_method_activity_dashboard", :locals => {:school => @school, :group=>params[:group], :subj=>subj, :duration=>duration, :tl_sessions=>tl_sessions, :start_date=>start_date, :activity=>activity, :columns=>columns, :task_details=> toggle}

  end

  def toggle_subject_dashboard_details
    initialize_parameters
    activity = TlActivityType.find_by_id(params[:activity_id])
    toggle = params[:task_details].to_i == 1 ? true:false  
    columns = params[:columns]
    session_count=[]
    subject = SubjectArea.find_by_public_id(params[:subject_id]) rescue nil
    month=[]
    idx = 0
    until idx == columns.size
      columns[idx] = columns[idx].to_i
      session_count[idx] = params[:session_count][idx].to_i
      month[idx] = params[:month][idx]=="" ? nil : DateTime.parse(params[:month][idx])    
      idx += 1
    end
    render :partial => "/apps/time_learning/subject_method_activity_dashboard", :locals => {:school => @school, :group=>params[:group], :subject=>subject, :month=> month, :session_count=>session_count, :activity=>activity, :columns=>columns, :task_details=> toggle}
  end

  def toggle_teacher_dashboard_details
    initialize_parameters
    activity = TlActivityType.find_by_id(params[:activity_id])
    toggle = params[:task_details].to_i == 1 ? true:false  
    columns = params[:columns]
    sessions=[]
    idx = 0
    until idx == columns.size
      columns[idx] = columns[idx].to_i
      sessions[idx] = TltSession.find_by_id(params[:session_ids][idx]) rescue nil
      idx += 1
    end
    render :partial => "/apps/time_learning/teacher_method_activity_dashboard", :locals => {:teacher => @teacher, :group=>params[:group], :subject=>@subject, :sessions=>sessions,:columns=>columns, :activity=>activity, :task_details=> toggle}
  end

  
  def toggle_method
    initialize_parameters
    app_method = AppMethod.find_by_id(params[:app_method_id])
    if @current_organization.itl_org_option.app_methods.include?(app_method)
      @current_organization.itl_org_option.itl_org_option_app_methods.for_app(app_method).destroy_all
    else
      @current_organization.itl_org_option.app_methods<<app_method
      unless @current_organization.itl_templates.collect{|t| t.app_methods}.flatten.uniq.include?(app_method)
        template = ItlTemplate.new
        template.name = app_method.name
        template.description = ""
        @current_organization.itl_templates<<template
        template.app_methods<<app_method
      end
    end
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}   
  end

  def toggle_template
    initialize_parameters
    template = ItlTemplate.find_by_id(params[:itl_template_id])
    template.update_attributes(:is_enabled=>!template.is_enabled)
    render :partial => "manage_templates"
  end

  def toggle_template_method
    initialize_parameters
    app_method = AppMethod.find_by_id(params[:app_method_id])
    template = ItlTemplate.find_by_id(params[:itl_template_id])
    if template.app_methods.include?(app_method)
      template.itl_template_app_methods.for_app(app_method).destroy_all 
      template.itl_template_filters.each do |filter|
        if app_method.tl_activity_types.include?(filter.tl_activity_type_task.tl_activity_type)
          filter.destroy
         end
      end
    else
      template.app_methods<<app_method
    end
    render :partial => "/apps/time_learning/manage_filters", :locals=>{:template => template}
  end
    
  def toggle_template_filter
    initialize_parameters
    template = ItlTemplate.find_by_id(params[:itl_template_id])
    if template.tl_activity_type_tasks.include?(@task)
      template.itl_template_filters.for_task(@task).destroy_all
    else
      template.tl_activity_type_tasks<<@task
    end
    render :partial => "/apps/time_learning/manage_filters", :locals=>{:template => template}
  end

  def copy_template
    initialize_parameters
    template = ItlTemplate.find_by_id(params[:itl_template_id])rescue nil
    if template 
      new_template =@current_organization.itl_templates.new
      new_template.name = template.name
      new_template.description = template.description
      if new_template.save
        new_template.app_methods << template.app_methods
        new_template.tl_activity_type_tasks << template.tl_activity_type_tasks
      end
    end
    redirect_to :action => 'manage_filters', :organization_id => @current_organization
  end

  def destroy_template
    initialize_parameters
    template = ItlTemplate.find_by_id(params[:itl_template_id])rescue nil
    if template 
      template.destroy
    end
    render :partial => "manage_templates"
  end


  def show_template

    initialize_parameters

  end
  
  def edit_template
    initialize_parameters
    if params[:function]=="new"
      @itl_template = ItlTemplate.new
      @itl_template.name = params[:name]=="" ? "New Template Name" : params[:name]
      if @itl_template.save
        flash[:notice] = "Template Created"
        @current_organization.itl_templates<<@itl_template
        @itl_template = @current_organization.itl_templates.last
      end
    elsif params[:function] == "update"
      @itl_template = ItlTemplate.find_by_id(params[:itl_template_id])rescue nil
        if @itl_template.update_attributes(:name=>params[:name], :description=>params[:description])
          flash[:notice] = "Template Updated"       
        else
         flash[:error] = "Template Not Updated"  
        end
      render :partial => "/apps/time_learning/edit_template", :locals => {:template => @itl_template}  
    else
       @itl_template = ItlTemplate.find_by_id(params[:itl_template_id])rescue nil         
    end
  end
    
  def toggle_filter
    initialize_parameters
    if @current_organization.itl_org_option.tl_activity_type_tasks.include?(@task)
      @current_organization.itl_org_option.itl_org_option_filters.for_task(@task).destroy_all
    else
      @current_organization.itl_org_option.tl_activity_type_tasks<<@task
    end
    render :partial => "/apps/time_learning/manage_filters", :locals=>{:app=>@app, :app_method => @task.tl_activity_type.app_method}   
  end

  def toggle_concurrent
    initialize_parameters

    @current_organization.itl_org_option.update_attributes(:is_concurrent => !@current_organization.itl_org_option.is_concurrent)
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}   
  end

  def toggle_finalize
    initialize_parameters

    @current_organization.itl_org_option.update_attributes(:is_teacher_finalize => !@current_organization.itl_org_option.is_teacher_finalize)
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}   
  end
  def toggle_conversation
    initialize_parameters

    @current_organization.itl_org_option.update_attributes(:is_conversations => !@current_organization.itl_org_option.is_conversations)
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}   
  end
  
  def toggle_thresholds
    initialize_parameters

    @current_organization.itl_org_option.update_attributes(:is_thresholds => !@current_organization.itl_org_option.is_thresholds)
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}   
  end

  def toggle_belt_ranking
    initialize_parameters

    @current_organization.itl_org_option.update_attributes(:is_belt_ranking => !@current_organization.itl_org_option.is_belt_ranking)
    render :partial => "/apps/time_learning/manage_options_params", :locals=>{:app=>@app}   
  end

  def manage_belt_rankings

    initialize_parameters

  end

  def manage_belt_user

    initialize_parameters

  end


  def manage_filters
    initialize_parameters
  end

  def manage_template
    initialize_parameters
    if params[:function]=="new"
      @itl_template = ItlTemplate.new
      @itl_template.name = params[:name]
      if @itl_template.save
        flash[:notice] = "Template Created."
        @current_organization.itl_templates<<@itl_template
      else
        flash[:error] = @itl_template.errors.full_messages.to_sentence
      end
    elsif params[:function]=="default"
      @current_organization.itl_templates.default.each do |def_temp|
        def_temp.update_attributes(:is_default=>false)
      end
      @itl_template.update_attributes(:is_default=>true)
    end
    render :partial => "manage_templates"
  end


  def update_user_belt
    initialize_parameters
    
    if params[:rank_id] == "99"
      if @user.user_itl_belt_rank then @user.user_itl_belt_rank.destroy end
        
    elsif params[:rank_id]==""  
      if @user.user_itl_belt_rank && params[:justify]!="" 
         unless @user.user_itl_belt_rank.update_attributes(:justification => params[:justify])    
          flash[:error] = @user.user_itl_belt_rank.errors.full_messages.to_sentence
        end       
      end 
      
    else  
      if @user.user_itl_belt_rank && params[:justify]!="" then @user.user_itl_belt_rank.destroy end
      create_belt_for(@user, params[:rank_id].to_i, params[:justify], @current_user)
    end
    render :partial => "/apps/time_learning/manage_belt_user", :locals => {:observer=> User.find_by_public_id(params[:user_id]), :app=>@app}  
  end


   private

  def ctl_allowed?
    @current_application = CoopApp.ctl
    current_app_enabled_for_current_org?
  end


  def student_itl_survey(session)
      session.update_attributes(:student_survey_date => Date.today)
      audience = @app.tlt_survey_audiences.student.first
      type = @app.tlt_survey_types.observation.first
      schedule_survey_app(session, session.organization, session.subject_area_id, audience, type, nil, nil, type.notify_default(audience), type.anon_default(audience))
      refresh_session
  end

  def reset_dashboard_impacts (session_id)
    session = TltSession.find_by_id(session_id) rescue nil
    unless session.nil?
      session.tlt_session_logs.each do |log|
      #  dashboard = TltDashboard.find (:first, :conditions => ["tlt_session_id = ? && tl_activity_type_task_id = ?", session.id, log.tl_activity_type_task_id])
        dashboard = session.dashboard_for_strategy(log.tl_activity_type_task)
     #   same_task_logs = TltSessionLog.find (:all, :conditions => ["tlt_session_id = ? && tl_activity_type_task_id = ?", session.id, log.tl_activity_type_task_id])
        same_task_logs = session.logs_for_strategy(log.tl_activity_type_task)
        total = same_task_logs.collect{ |t| t.impact_score}.compact.sum
        count = same_task_logs.collect{ |t| t.impact_score}.compact.size
        dashboard.update_attributes(:impact_total => total, :impact_count => count)
      end
    end
  end
 
 
  def initialize_parameters
    @current_organization.itl_set_org_options
    if params[:classroom_id]
      @classroom =Classroom.find_by_public_id(params[:classroom_id])  rescue nil
    end
    if params[:period_id]
      @period =ClassroomPeriod.find_by_public_id(params[:period_id])  rescue nil
    end
    if params[:teacher_id]
      @teacher = User.find_by_public_id(params[:teacher_id]) rescue nil
    else
      @teacher = @current_user
    end
    if params[:school_id]
      @school = Organization.find_by_public_id(params[:school_id]) rescue nil
    end
    if params[:user_id]
      @user = User.find_by_public_id(params[:user_id]) rescue nil
    end
    if params[:tlt_session_id]
      @tlt_session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
    end

    if params[:tlt_log_id]
      @tlt_log = TltSessionLog.find_by_public_id(params[:tlt_log_id])
    end

    if params[:tlt_task_id]
      @task = TlActivityTypeTask.find_by_id(params[:tlt_task_id]) rescue nil
    end

    if params[:activity_id]
      @activity = TlActivityType.find_by_id(params[:activity_id]) rescue nil
    end

    if params[:subject_area_id]
      @tlt_subject = SubjectArea.find_by_public_id(params[:subject_area_id]) rescue nil
    end
    
    if params[:survey_id]
      @survey = TltSurveyQuestion.find_by_public_id(params[:survey_id]) rescue nil
    end
    
    if params[:tlt_survey_question_id]
      @survey_question = TltSurveyQuestion.find_by_public_id(params[:tlt_survey_question_id]) rescue nil
    end   
    if params[:tlt_survey_audience_id]
      @audience = TltSurveyAudience.find_by_public_id(params[:tlt_survey_audience_id]) rescue nil
    end 
    if params[:audience_id]
      @audience = TltSurveyAudience.find_by_id(params[:audience_id]) rescue nil
    end      
    if params[:tlt_survey_type_id]
      @survey_type = TltSurveyAudience.find_by_public_id(params[:tlt_survey_type_id]) rescue nil
    end
    if params[:survey_type_id]
      @survey_type = TltSurveyType.find_by_id(params[:survey_type_id]) rescue nil
    end  
    if params[:subject_area_id]
      @subject_area = SubjectArea.find_by_public_id(params[:subject_area_id]) rescue nil
      unless @subject_area
        @subject_area = @subject_area.parent_id.nil? ? @subject_area : @subject_area.parent
      end
    end 
    if params[:subject_id]
      @subject = SubjectArea.find_by_public_id(params[:subject_id]) rescue nil
    else
       @subject = nil
    end    
       
    if params[:schedule_id]
      @schedule = SurveySchedule.find_by_public_id(params[:schedule_id]) rescue nil
    end

    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    end
    unless @app
      @app = CoopApp.itl rescue CoopApp.find(:first)
    end

    if params[:hat]
      @hat = params[:hat]
    end

    if params[:itl_template_id] 
      @itl_template = ItlTemplate.find_by_id(params[:itl_template_id])rescue nil
    end  
      
    @admin = @current_user.ctl_admin_for_org?(@current_organization)

  end

  def clean_unresolved_observer_sessions
    TltSession.for_observer(@current_user).select{|s| s.tlt_session_logs.size == 0}.each do |session|
      session.destroy      
    end  
    open_sessions = TltSession.for_observer(@current_user).select{|s| !s.logs_are_closed} 
    unless open_sessions.empty?
      redirect_to :controller => 'apps/panel', :action => 'track_session', :user_id=> @current_user, :organization_id => @current_organization, :tlt_session_id => open_sessions.last, :suspended => true
    end   
  end

  def clean_unresolved_teacher_sessions
    @current_user.tlt_sessions.select{|s| s.tlt_session_logs.size == 0 || !s.logs_are_closed}.each do |session|
        resolve_session(session)
      end   
  end


  def resolve_session(session)
    if session.tlt_session_logs.size == 0 
      session.destroy
    else
       close_session(session)
    end    
  end

  def refresh_session
    @tlt_session = TltSession.find_by_public_id(params[:tlt_session_id]) rescue nil
  end

  def create_belt_for(user,belt_id, note, grantor)
      new_user_belt = UserItlBeltRank.new
      new_user_belt.user_id = user.id
      new_user_belt.itl_belt_rank_id = belt_id
      new_user_belt.grantor_name = grantor.last_name_first
      new_user_belt.justification = note
      if new_user_belt.save
        Notifier.deliver_itl_belt_change(:user => user, :sender => grantor, :rank => belt_id,:message => note, :fsn_host => request.host_with_port)
        flash[:notice] =  user.first_name + " Has Been Notified"
      else
        flash[:error] = new_user_belt.errors.full_messages.to_sentence
      end
  end
  
  def update_dashboard(session)
    
    unless session.tlt_dashboards.empty?
      session.tlt_dashboards.destroy_all
    end
    session.tlt_session_logs.collect{|l| l.tl_activity_type_task_id}.uniq.each do |type_task_id|
      tasks = session.tlt_session_logs.select{|t| t.tl_activity_type_task_id == type_task_id}
      activity_task = TlActivityTypeTask.find_by_id(type_task_id) rescue nil
      unless activity_task.nil?
        dashboard = TltDashboard.new
        dashboard.tlt_session_id = session.id
        dashboard.user_id = session.user_id
        dashboard.tracker_id = session.tracker_id
        dashboard.classroom_id = session.classroom_id
        dashboard.topic_id = session.topic_id
        dashboard.organization_id = session.organization_id
        dashboard.tl_activity_type_task_id = type_task_id
        dashboard.tl_activity_type_id = activity_task.tl_activity_type_id
        dashboard.subject_area_id = session.subject_area_id
        dashboard.duration_secs = tasks.collect{|tsk| tsk.duration}.sum rescue 0
        dashboard.duration_pct = session.duration == 0 ? 0 : (100*dashboard.duration_secs.to_f/session.duration.to_f).round
        dashboard.segments = tasks.size
        dashboard.involve_total = tasks.collect{ |t| t.involve_score}.compact.sum 
        dashboard.involve_count = tasks.collect{ |t| t.involve_score}.compact.size
        dashboard.impact_total = tasks.collect{ |t| t.impact_score}.compact.sum 
        dashboard.impact_count = tasks.collect{ |t| t.impact_score}.compact.size 
        dashboard.save
      end
    end 
  end

  def replace_dashboards(session)
    if session.tlt_dashboards.destroy_all
      update_dashboard(session)
    end
  end


  def itl_groupings
    @itl_groups = []
    @itl_groups[0] = "teacher"
    @itl_groups[1] = "observer"
    @itl_groups[2] = "subject" 
    @itl_groups[3] = "month"
  end

  def research_views
    @res_views = []
    @res_views[0] = ["Strategy Emphasis", "a"]
    @res_views[1] = ["Classroom Chronology", "b"]
  end

  def color_palette
    @colors = []
    @colors[0] = "#3ba7fb"
    @colors[1] = "#81c66e"
    @colors[2] = "#f4da48"
    @colors[3] = "#fd9896" 
  end

  def involvement_color(inv)
    if inv.nil?
      "#ffffff"
      elsif inv >= 3.5
        @colors[0]
      elsif inv >=2.5
        inv_color = @colors[1]
      elsif inv >=1.5
        @colors[2]
      else 
        @colors[3]
    end
  end

  def research_color(score)
    if score.nil?
      "#ffffff"
      elsif score == 4
        @colors[0]
        elsif score == 3
          @colors[1]
          elsif score == 2
            @colors[2]
            else 
              @colors[3]
    end
  end
  
  def category_color(abbrev)
    if abbrev.nil?
      "#ffffff"
    elsif abbrev == "NP"
        @colors[1]
        elsif abbrev == "TD"
          @colors[0]
          elsif abbrev == "SD"
            @colors[0]
            else 
              @colors[1]
    end
  end

  def create_summary_data(session)
    summary = ItlSummary.find(:first, :conditions=>["classroom_id=? AND yr_mnth_of=? AND itl_belt_rank_id = ?", session.classroom_id,session.session_date.beginning_of_month, session.itl_belt_rank_id]) rescue nil
    if summary
     summary.observation_count += 1
     summary.classroom_duration += session.duration
     summary.observation_duration += session.session_length
    else
      summary = ItlSummary.new
      summary.organization_id = session.organization_id
      summary.classroom_id = session.classroom_id
      summary.yr_mnth_of = session.session_date.beginning_of_month
      summary.subject_area_id = session.subject_area_id
      summary.organization_type_id = session.organization.organization_type_id
      summary.observation_count = 1
      summary.classroom_duration = session.duration
      summary.observation_duration = session.session_length
      summary.itl_belt_rank_id = session.itl_belt_rank_id
    end
    if summary.save
        session.tlt_session_logs.collect{|l| l.tl_activity_type_task}.uniq.each do |strat|
          strategy_summary = summary.itl_summary_strategies.for_strategy(strat).first 
          if strategy_summary
            strategy_summary.duration += session.tlt_session_logs.for_task(strat).collect{|l| l.duration}.sum
            strategy_summary.segments += session.tlt_session_logs.for_task(strat).size           
            strategy_summary.engage_total += session.tlt_session_logs.for_task(strat).collect{|l| l.involve_score}.compact.sum
            strategy_summary.engage_segments += session.tlt_session_logs.for_task(strat).select{|l| l.involve_score}.size
            strategy_summary.save
          else
            strategy_summary = summary.itl_summary_strategies.new
            strategy_summary.tl_activity_type_task_id = strat.id
            strategy_summary.duration = session.tlt_session_logs.for_task(strat).collect{|l| l.duration}.sum
            strategy_summary.segments = session.tlt_session_logs.for_task(strat).size           
            strategy_summary.engage_total = session.tlt_session_logs.for_task(strat).collect{|l| l.involve_score}.compact.sum
            strategy_summary.engage_segments = session.tlt_session_logs.for_task(strat).select{|l| l.involve_score}.size
            strategy_summary.save
          end
        end
    end
  end

  def user_logs_strategies(entity, subj, start_date, end_date, belt)
    if entity
      @logs = entity.itl_summaries_between_dates_subject_belt(subj, start_date, end_date, belt).collect{|ses| ses.tlt_session_logs}.flatten.compact.select{|l| AppMethod.rs.first.tl_activity_types.include?(l.tl_activity_type_task.tl_activity_type)}  
      @sess_count = @logs.collect{|l| l.tlt_session}.uniq.size
      @strats = @logs.collect{|l| l.tl_activity_type_task}.uniq rescue []
    else
      @logs = []
      @sess_count = 0
      @strats = []
    end
   end

  def summary_logs_strategies(entity, subj, start_date, end_date, population, belt)
    if entity
      unless population
        @logs = entity.itl_summaries_between_dates_subject_belt(subj, start_date, end_date, belt).collect{|smry| smry.itl_summary_strategies}.flatten.compact.select{|l| AppMethod.rs.first.tl_activity_types.include?(l.tl_activity_type_task.tl_activity_type)}   
        @sess_count = entity.itl_summaries_between_dates_subject_belt(subj, start_date, end_date, belt).collect{|smry| smry.observation_count}.sum
      else
        @logs = @current_organization.organization_type.itl_summaries_between_dates_subject_belt(subj, start_date, end_date, belt).collect{|smry| smry.itl_summary_strategies}.flatten.compact.select{|l| AppMethod.rs.first.tl_activity_types.include?(l.tl_activity_type_task.tl_activity_type)}   
        @sess_count = @current_organization.organization_type.itl_summaries_between_dates_subject_belt(subj, start_date, end_date, belt).collect{|smry| smry.observation_count}.sum
      end
      @strats = @logs.collect{|l| l.tl_activity_type_task}.uniq rescue []
    else
      @logs = []
      @sess_count = 0
      @strats = []
    end
  end

  def teacher_update?(session)
  ( !session.is_teacher_done  && (session.user_id == @current_user.id) && !session.is_final)
  end

  def observer_update?(session)
  ( !session.is_observer_done  && (session.tracker_id == @current_user.id)&& !session.is_final)
  end

end
