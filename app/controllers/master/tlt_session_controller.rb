class Master::TltSessionController < Master::ApplicationController

  layout "master"
  
  before_filter :find_session
  
  def index
    @sessions = TltSession.all.order('session_date DESC')
  end

  def completed_crud_conversion
  end


  def delete
    if request.post?
      @session.destroy
      flash[:notice] = "Successfully removed TL Session #{@session.id}."
      redirect_to :action => :index
    end
  end
 
   def update_session_dashboards

        if @session.is_manual
           session_duration = @session.measured_time   
        else
          session_duration = @session.tlt_session_logs.last.start_time + @session.tlt_session_logs.last.duration - @session.tlt_session_logs.first.start_time        
        end  
        @session.update_attributes(:duration => session_duration)
        find_session
        @session.tlt_dashboards.each do |dash|
          dash.destroy
        end
         TlActivityTypeTask.all.each do |task|
           logs = @session.tlt_session_logs.for_task(task) rescue []
           unless logs.empty?
              dashboard = TltDashboard.new             
              dashboard.tlt_session_id = @session.id
              dashboard.user_id = @session.user_id
              dashboard.tracker_id = @session.tracker_id
              dashboard.classroom_id = @session.classroom_id
              dashboard.topic_id = @session.topic_id
              dashboard.organization_id = @session.organization_id             
              dashboard.subject_area_id = @session.subject_area_id
              dashboard.tl_activity_type_task_id = task.id
              dashboard.tl_activity_type_id = task.tl_activity_type_id              
              dashboard.duration_secs = logs.collect{|tsk| tsk.duration}.sum             
              dashboard.duration_pct = session_duration == 0 ? 0 : (100*dashboard.duration_secs.to_f/session_duration.to_f).round.to_i
              dashboard.segments = logs.size                         
              dashboard.involve_total = logs.collect{ |t| t.involve_score}.compact.sum 
              dashboard.involve_count = logs.collect{ |t| t.involve_score}.compact.size
              dashboard.impact_total = logs.collect{ |t| t.impact_score}.compact.sum 
              dashboard.impact_count = logs.collect{ |t| t.impact_score}.compact.size 
              dashboard.save
           end          
        end
      redirect_to :action => :index
   end 

  def add_classroom_names_to_sessions
    sessions = TltSession.clsrm_dashboard
    sessions.each do |session|
      duration = session.duration < 900 ? 900 : session.duration
      classroom_name = session.classroom ?  session.classroom.course_name : "* Removed Classroom *"
      period_name = session.classroom_period ? session.classroom_period.name : "* Removed Period *"
      session.update_attributes(:duration=> duration, :classroom_name=>classroom_name, :class_period_name=> period_name)
    end
      redirect_to :action => :completed_crud_conversion   
  end

   def update_session_summary_tables
  
      ItlSummary.destroy_all
      
      TltSession.final.each do |session|
        yr_month = session.session_date.year.to_i*100 + session.session_date.month.to_i
         # summary = ItlSummary.find(:first, :conditions=>["classroom_id=? AND yr_mnth=?", session.classroom_period.classroom_id,yr_month]) rescue nil
        summary = (session.classroom_period.nil? || session.classroom_period.classroom.nil?) ? nil :session.classroom_period.classroom.itl_summaries.for_month(yr_month).first
        if summary
         summary.observation_count += 1
         summary.classroom_duration += session.duration
         summary.observation_duration += session.session_length
        else
          summary = ItlSummary.new
          summary.organization_id = session.organization_id
          summary.classroom_id = session.classroom_period.classroom_id
          summary.yr_mnth = yr_month
          summary.subject_area_id = session.subject_area_id
          summary.organization_type_id = session.organization.organization_type_id
          summary.observation_count = 1
          summary.classroom_duration = session.duration
          summary.observation_duration = session.session_length
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

      redirect_to :action => :completed_crud_conversion 
   end 

   def update_all_session_dashboards
  
      TltSession.backlog.each do |session|

        if session.duration < session.session_length
          session.update_attributes(:duration => session.session_length) 
        end
        unless session.tlt_dashboards.empty? 
          session.tlt_dashboards.destroy_all
        end 
      end

      TltSession.final.each do |session|      
        if session.duration < session.session_length
          session.update_attributes(:duration => session.session_length) 
        end
        session.tlt_dashboards.destroy_all
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
      redirect_to :action => :index
   end 
 
   def create_class_periods
    sessions = TltSession.all
    sessions.each do |ses|
 
      if ses.classroom.classroom_periods.size == 0
          @period = ClassroomPeriod.new
          @period.classroom_id = ses.classroom_id
          @period.name = "Period 1"
          @period.week_duration = 240  
          if @period.save
            @period_user = ClassroomPeriodUser.new
            @period_user.user_id = ses.user_id
            @period_user.is_teacher = true
            @period_user.is_student = false
            @period.classroom_period_users<<@period_user
          end
      end
     
      period = ses.classroom.classroom_periods.first
      ses.update_attributes(:classroom_period_id => period.id)
     end
    redirect_to :action => :completed_crud_conversion
  end

#   def create_classroom_periods
#    Classroom.active.each do |clsrm|
#     
#      if clsrm.classroom_periods.size == 0
#        @period= ClassroomPeriod.new
#        @period.classroom_id = clsrm.id
#        @period.name = "Class Offering Period 1"
#        @period.week_duration = 260  
#        if @period.save
#          clsrm.leaders_old.each do |teacher|
#            @period_user = ClassroomPeriodUser.new
#            @period_user.user_id = teacher.id
#            @period_user.is_teacher = true
#            @period_user.is_student = false
#            @period.classroom_period_users<<@period_user
#          end
#        end
#     end
#     end
#    redirect_to :action => :completed_crud_conversion
#  end

  def add_instruction_id_to_schedules
    SurveySchedule.all.each do |survey|
      instruction_id = survey.survey_instruction.nil? ? nil : survey.survey_instruction.id
      survey.update_attribute("survey_instruction_id", instruction_id)
    end
      redirect_to :action => :completed_crud_conversion   
  end


 def create_survey_schedules
#   TltSession.all.each do |session|
#     if session.tlt_survey_responses.size > 0
#        session_audience = session.tlt_survey_responses.first.tlt_survey_audience
#        session_type = session.tlt_survey_responses.first.tlt_survey_type
#        session_limit = session_audience.id == 3 ? 200 : 1        
#        user_id = session.user_id
#        org_id = session.organization_id
#        subj_id = session.subject_area_id
#        if session.survey_schedules.size == 0
#          schedule_survey(session, session_audience, session_type, session_limit, false, user_id, org_id, subj_id) 
#        end
#        refreshed_session = TltSession.find_by_id(session.id)
#        refreshed_session.tlt_survey_responses.each do |resp|
#          resp.update_attribute("survey_schedule_id", refreshed_session.survey_schedules.first.id)
#        end
#     else
 #      unless session.is_observer_done
#          session_audience = CoopApp.itl.tlt_survey_audiences.observer.first
#          session_type = CoopApp.itl.tlt_survey_types.observation.first
#          user_id = session.user_id
#          org_id = session.organization_id
#          subj_id = session.subject_area_id
#          session_limit =  1
#          schedule_survey(session, session_audience, session_type, session_limit, false, user_id, org_id, subj_id) 
#        end
#       unless session.is_teacher_done
#          session_audience = CoopApp.itl.tlt_survey_audiences.teacher.first
#          session_type = CoopApp.itl.tlt_survey_types.observation.first
#          user_id = session.user_id
#          org_id = session.organization_id
#          subj_id = session.subject_area_id
#          session_limit =  1
#          schedule_survey(session, session_audience, session_type, session_limit, false, user_id, org_id, subj_id) 
#        end
#     end
#   end
#   UserDlePlan.all.each do |session|
#     if session.tlt_survey_responses.size > 0
#        session_audience = session.tlt_survey_responses.first.tlt_survey_audience
#        session_type = session.tlt_survey_responses.first.tlt_survey_type
#        user_id = session.user_id
#        org_id = session.user.organization.id
#        subj_id = nil
#        session_limit =  1
#        if session.survey_schedules.size == 0
#          schedule_survey(session, session_audience, session_type, session_limit, false, user_id, org_id, subj_id) 
#        end
#        refreshed_session = UserDlePlan.find_by_id(session.id)
#        refreshed_session.tlt_survey_responses.each do |resp|
#          resp.update_attribute("survey_schedule_id", refreshed_session.survey_schedules.first.id)
#        end
#     else
#       if session.is_current
#          session_audience = CoopApp.pd.tlt_survey_audiences.teacher.first
#          if session.dle_cycle_id == 1 then session_type = CoopApp.pd.tlt_survey_types.pre.first end
#          if session.dle_cycle_id == 2 then session_type = CoopApp.pd.tlt_survey_types.disc.first end
#          if session.dle_cycle_id == 3 then session_type = CoopApp.pd.tlt_survey_types.learn.first end
#          if session.dle_cycle_id == 4 then session_type = CoopApp.pd.tlt_survey_types.post.first end
#          user_id = session.user_id
#          org_id = session.user.organization.id
#          subj_id = nil
#          session_limit =  1
#          schedule_survey(session, session_audience, session_type, session_limit, true, user_id, org_id, subj_id) 
#        end
#     end
#   
#   end
#   TltDiagnostic.all.each do |session|
#     if session.tlt_survey_responses.size > 0
#        session_audience = session.tlt_survey_responses.first.tlt_survey_audience
 #       session_type = session.tlt_survey_responses.first.tlt_survey_type
#        user_id = session.user_id
#        org_id = session.organization_id
#        subj_id = session.subject_area_id
#        session_limit = 1        
#        if session.survey_schedules.size == 0
#          schedule_survey(session, session_audience, session_type, session_limit, false, user_id, org_id, subj_id) 
#        end
#        refreshed_session = TltDiagnostic.find_by_id(session.id)
#        refreshed_session.tlt_survey_responses.each do |resp|
#          resp.update_attribute("survey_schedule_id", refreshed_session.survey_schedules.first.id)
#        end
#      end
#   end
#    redirect_to :action => :completed_crud_conversion
 end 
  
  def adjust_involve_col
    sessions = TltSession.all
    sessions.each do |ses|
 
    ses.tlt_session_logs.each do |log|
      if log.involve == "All" then score = 4 end
      if log.involve == "Most" then score = 3 end
      if log.involve == "Some" then score = 2 end
      if log.involve == "Few" then score = 1 end
      log.update_attributes(:involve_score => score)
     end

    ses.tlt_dashboards.each do |db|
      
      all = db.involve_all.nil? ? 0 : db.involve_all
      most = db.involve_most.nil? ? 0 : db.involve_most
      some = db.involve_some.nil? ? 0 : db.involve_some
      few = db.involve_few.nil? ? 0 : db.involve_few    
      
      
      total = all*4 + most*3 + some*2 + few*1
      count = all + most + some + few
      db.update_attributes(:involve_total => total, :involve_count => count)     
      end
    end
    redirect_to :action => :completed_crud_conversion
  end 
  
  private
  
  def find_session
    if params[:id]
      @session = TltSession.find_by_id(params[:id]) rescue nil
    end
  end  

#  def schedule_survey(entity, audience, type, limit, active, user_id, org_id, subj_id)
#    if audience && type
#      schedule = entity.survey_schedules.new
#      schedule.organization_id = org_id
#      schedule.subject_area_id = subj_id
#      schedule.schedule_start = Date.today
#      schedule.user_id = user_id
#      schedule.tlt_survey_audience_id = audience.id
#      schedule.tlt_survey_type_id = type.id
#      schedule.survey_instruction_id = SurveyInstruction.for_audience(audience).for_type(type).first.id rescue 999
#      schedule.max_responses = limit
#      schedule.is_active = active
#      schedule.save
#    end
#  end

end
