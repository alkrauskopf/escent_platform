class TlActivityType < ActiveRecord::Base

  has_many :tl_activity_type_tasks, :dependent => :destroy
  has_many :tlt_dashboards, :dependent => :destroy
  has_many :tlt_dashboard_lessons

  belongs_to :tlt_diagnostic_lesson  
  belongs_to :app_method
  
  scope :by_position, :order => "seq_num"



  def activity_pct(session)
    cum_duration = session.tlt_session_logs.select{|l| l.tl_activity_type_task.tl_activity_type == self}.collect{|l| l.duration}.sum
    pct = (100*cum_duration.to_f/session.measured_time.to_f).round rescue 0
  end

  def activity_population_pct(session)
    sessions = TltSession.for_subject(session.subject_area)
    tot_time = sessions.collect{|s| s.measured_time}.sum
    cum_duration = sessions.collect{|s| s.tlt_session_logs}.flatten.select{|l| l.tl_activity_type_task.tl_activity_type == self}.collect{|l| l.duration}.sum
    pct = (100*cum_duration.to_f/tot_time.to_f).round
   end

  def stats_for_subject_org_since(subject, organization, since )

    all_sessions = TltSession.find(:all, :conditions =>["subject_area_id =? AND session_date >= ? AND organization_id = ? AND is_final", subject.id, since, organization.id])
    num_sessions = all_sessions.size
    dashboards = all_sessions.collect{|s| s.tlt_dashboards}.flatten.select{ |d| d.tl_activity_type_id == self.id}
    sessions_duration = all_sessions.collect{|s| s.session_length}.sum
    activity_duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? nil : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = sessions_duration == 0 ? 0 : (100*activity_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (activity_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, activity_duration]
  end

  def sumry_stats_for_subject_org_since(subject, organization, since, population )
#    all_sessions = population ? (organization.organization_type.itl_summaries.since_date(since).for_subject(subject) rescue [] ) : (organization.itl_summaries.since_date(since).for_subject(subject) rescue [])
    all_sessions = population ? (organization.organization_type.itl_summaries_since_date_subject(subject, since) rescue [] ) : (organization.itl_summaries_since_date_subject(subject, since) rescue [])
    num_sessions = all_sessions.collect{|s| s.observation_count}.sum
    sessions_duration = all_sessions.collect{|s| s.observation_duration}.sum
    dashboards = all_sessions.collect{|s| s.itl_summary_strategies}.flatten.select{ |d| d.tl_activity_type_task.tl_activity_type_id == self.id}
    activity_duration = dashboards.collect{|d| d.duration}.compact.sum
    involve_score = dashboards.collect{|d| d.engage_total}.compact.sum
    involve_count = dashboards.collect{|d| d.engage_segments}.compact.sum
    avg_involve = involve_count == 0 ? nil: involve_score.to_f/involve_count.to_f
    pct_duration = sessions_duration == 0 ? 0 : (100*activity_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (activity_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, 0, dashboards.size, sessions_duration, activity_duration]
  end

  def sumry_stats_for_subject_org_between(subject, organization, start_date, end_date, population )
#    all_sessions = population ? (organization.organization_type.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue []) : (organization.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue []) 
    all_sessions = population ? (organization.organization_type.itl_summaries_for_month_subject(subject, month) rescue []) : (organization.itl_summaries_for_month_subject(subject, month) rescue []) 
    num_sessions = all_sessions.collect{|s| s.observation_count}.sum
    sessions_duration = all_sessions.collect{|s| s.observation_duration}.sum
    dashboards = all_sessions.collect{|s| s.itl_summary_strategies}.flatten.select{ |d| d.tl_activity_type_task.tl_activity_type_id == self.id}
    activity_duration = dashboards.collect{|d| d.duration}.compact.sum
    involve_score = dashboards.collect{|d| d.engage_total}.compact.sum
    involve_count = dashboards.collect{|d| d.engage_segments}.compact.sum
    avg_involve = involve_count == 0 ? nil : involve_score.to_f/involve_count.to_f
    impact_total = dashboards.empty? ? 0 : dashboards.collect{|s| s.tl_activity_type_task.research * s.segments}.sum
    avg_impact = dashboards.empty? ? 0 : (impact_total.to_f/dashboards.collect{|s| s.segments}.sum.to_f).round.to_i
    pct_duration = sessions_duration == 0 ? 0 : (100*activity_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (activity_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, activity_duration]
  end

  def sumry_stats_for_subject_org_month(subject, organization, month, population )
#    all_sessions = population ? (organization.organization_type.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue []) : (organization.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue []) 
    all_sessions = population ? (organization.organization_type.itl_summaries_for_month_subject(subject, month) rescue []) : (organization.itl_summaries_for_month_subject(subject, month) rescue []) 
    num_sessions = all_sessions.collect{|s| s.observation_count}.sum
    sessions_duration = all_sessions.collect{|s| s.observation_duration}.sum
    dashboards = all_sessions.collect{|s| s.itl_summary_strategies}.flatten.select{ |d| d.tl_activity_type_task.tl_activity_type_id == self.id}
    activity_duration = dashboards.collect{|d| d.duration}.compact.sum
    involve_score = dashboards.collect{|d| d.engage_total}.compact.sum
    involve_count = dashboards.collect{|d| d.engage_segments}.compact.sum
    avg_involve = involve_count == 0 ? nil : involve_score.to_f/involve_count.to_f
    impact_total = dashboards.empty? ? 0 : dashboards.collect{|s| s.tl_activity_type_task.research * s.segments}.sum
    avg_impact = dashboards.empty? ? 0 : (impact_total.to_f/dashboards.collect{|s| s.segments}.sum.to_f).round.to_i
    pct_duration = sessions_duration == 0 ? 0 : (100*activity_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (activity_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, activity_duration]
  end

  def stats_for_subject_org_between(subject, organization, start_date, end_date )

    all_sessions = TltSession.find(:all, :conditions =>["subject_area_id =? AND session_date >= ? AND session_date <= ? AND organization_id = ? AND is_final", subject.id, start_date, end_date, organization.id])
    num_sessions = all_sessions.size
    dashboards = all_sessions.collect{|s| s.tlt_dashboards}.flatten.select{ |d| d.tl_activity_type_id == self.id}
    sessions_duration = all_sessions.collect{|s| s.session_length}.sum
    activity_duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? 0 : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = sessions_duration == 0 ? 0 : (100*activity_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (activity_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, activity_duration]
  end

  def stats_for_subject_since(subject, since,org_type_id )

    all_dashboards = TltDashboard.find(:all, :conditions =>["subject_area_id =? AND created_at >= ?", subject.id, since]).select{|d| d.organization.organization_type_id == org_type_id}
    dashboards = TltDashboard.find(:all, :conditions =>["tl_activity_type_id = ? AND subject_area_id =?  AND created_at >= ?", self.id, subject.id, since]).select{|d| d.organization.organization_type_id == org_type_id}    
    num_sessions = dashboards.collect{|d| d.tlt_session_id}.uniq.size
    total_duration = all_dashboards.collect{|d| d.duration_secs}.compact.sum
    duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? 0 : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = total_duration == 0 ? 0 : (100*duration.to_f/total_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, total_duration]
  end

  def stats_for_user_since(user, since )

    all_dashboards = TltDashboard.find(:all, :conditions =>["user_id =? AND created_at >= ?", user.id, since])
    dashboards = TltDashboard.find(:all, :conditions =>["tl_activity_type_id = ? AND user_id =?  AND created_at >= ?", self.id, user.id, since])       
    num_sessions = dashboards.collect{|d| d.tlt_session_id}.uniq.size
    total_duration = all_dashboards.collect{|d| d.duration_secs}.compact.sum
    duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? 0 : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = total_duration == 0 ? 0 : (100*duration.to_f/total_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, total_duration, num_sessions]
  end

  def stats_for_user_subject_since(user, subject, since )

    all_dashboards = TltDashboard.find(:all, :conditions =>["user_id =? AND subject_area_id =? AND created_at >= ?", user.id, subject.id, since])
    dashboards = TltDashboard.find(:all, :conditions =>["tl_activity_type_id = ? AND user_id =?  AND subject_area_id =? AND created_at >= ?", self.id, user.id, subject.id, since])       
    num_sessions = dashboards.collect{|d| d.tlt_session_id}.uniq.size
    total_duration = all_dashboards.collect{|d| d.duration_secs}.compact.sum
    duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? 0 : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = total_duration == 0 ? 0 : (100*duration.to_f/total_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, total_duration, num_sessions]
  end
end
