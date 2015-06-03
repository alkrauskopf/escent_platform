class TlActivityTypeTask < ActiveRecord::Base

  belongs_to :tl_activity_type

  has_many :tlt_session_logs
  has_many :tlt_dashboards, :dependent => :destroy
  has_many  :itl_summary_strategies, :dependent => :destroy
  has_one :itl_strategy_threshold, :dependent => :destroy
  has_one :tl_strategy_desc, :dependent => :destroy
  has_many :itl_org_option_filters, :dependent => :destroy
  has_many :itl_org_options, :through => :itl_org_option_filters
  has_many :itl_template_filters, :dependent => :destroy
  has_many :itl_templated, :through => :itl_template_filters
  has_many :itl_strategy_evidences, :dependent=> :destroy
  has_many :evidences, :through => :itl_strategy_evidences
      
  named_scope :by_position, :order => "position"
  named_scope :enabled, :conditions => ["is_enabled"], :order => "position"
  named_scope :for_position, lambda{|position| {:conditions => ["position = ? ", position]}}
  named_scope :for_activity, lambda{|activity| {:conditions => ["tl_activity_type_id = ? ", activity.id]}}


  def evidences_method(method)
    self.evidences.enabled.select{|s| s.tl_activity_type.app_method_id == method.id}.sort_by{|s| s.tl_activity_type.activity}
  end

  def stats_for_subject_org_since(subject, organization, since )

    all_sessions = TltSession.find(:all, :conditions =>["subject_area_id =? AND session_date >= ? AND organization_id = ? AND is_final", subject.id, since, organization.id])
    num_sessions = all_sessions.size
    dashboards = all_sessions.collect{|s| s.tlt_dashboards}.flatten.select{ |d| d.tl_activity_type_task_id == self.id}
    sessions_duration = all_sessions.collect{|s| s.session_length}.sum
    task_duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? 0 : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = sessions_duration == 0 ? 0 : (100*task_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (task_duration.to_f/num_sessions.to_f).round.to_i 
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, task_duration]
  end

  def sumry_stats_for_subject_org_since(subject, organization, since, population )
#    all_sessions = population ? (organization.organization_type.itl_summaries.since_date(since).for_subject(subject) rescue []) : (organization.itl_summaries.since_date(since).for_subject(subject) rescue [])
    all_sessions = population ? (organization.organization_type.itl_summaries_since_date_subject(subject, since) rescue []) : (organization.itl_summaries_since_date_subject(subject, since) rescue [])
    num_sessions = all_sessions.collect{|s| s.observation_count}.sum
    sessions_duration = all_sessions.collect{|s| s.observation_duration}.sum
    dashboards = all_sessions.collect{|s| s.itl_summary_strategies}.flatten.select{ |d| d.tl_activity_type_task_id == self.id}
    task_duration = dashboards.collect{|d| d.duration}.compact.sum
    involve_score = dashboards.collect{|d| d.engage_total}.compact.sum
    involve_count = dashboards.collect{|d| d.engage_segments}.compact.sum
    avg_involve = involve_count == 0 ? nil : involve_score.to_f/involve_count.to_f
    impact_total = dashboards.empty? ? 0 : dashboards.collect{|s| s.tl_activity_type_task.research * s.segments}.sum
    avg_impact = dashboards.empty? ? 0 : (impact_total.to_f/dashboards.collect{|s| s.segments}.sum.to_f).round.to_i
    pct_duration = sessions_duration == 0 ? 0 : (100*task_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (task_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, task_duration]
  end

  def sumry_stats_for_subject_org_between(subject, organization, start_date, end_date,population )
#    all_sessions = population ? (organization.organization_type.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue []) : (organization.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue [])
    all_sessions = population ? (organization.organization_type.itl_summaries_between_dates_subject(subject, start_date, end_date) rescue []) : (organization.itl_summaries_between_dates_subject(subject, start_date, end_date) rescue [])
    num_sessions = all_sessions.collect{|s| s.observation_count}.sum
    sessions_duration = all_sessions.collect{|s| s.observation_duration}.sum
    dashboards = all_sessions.collect{|s| s.itl_summary_strategies}.flatten.select{ |d| d.tl_activity_type_task_id == self.id}
    task_duration = dashboards.collect{|d| d.duration}.compact.sum
    involve_score = dashboards.collect{|d| d.engage_total}.compact.sum
    involve_count = dashboards.collect{|d| d.engage_segments}.compact.sum
    avg_involve = involve_count == 0 ? nil : involve_score.to_f/involve_count.to_f
    impact_total = dashboards.empty? ? 0 : dashboards.collect{|s| s.tl_activity_type_task.research * s.segments}.sum
    avg_impact = dashboards.empty? ? 0 : (impact_total.to_f/dashboards.collect{|s| s.segments}.sum.to_f).round.to_i
    pct_duration = sessions_duration == 0 ? 0 : (100*task_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (task_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, task_duration]
  end

  def sumry_stats_for_subject_org_month(subject, organization, month, population )
#    all_sessions = population ? (organization.organization_type.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue []) : (organization.itl_summaries.between_dates(start_date, end_date).for_subject(subject) rescue [])
    all_sessions = population ? (organization.organization_type.itl_summaries_for_month_subject(subject, month) rescue []) : (organization.itl_summaries_for_month_subject(subject, month) rescue [])
    num_sessions = all_sessions.collect{|s| s.observation_count}.sum
    sessions_duration = all_sessions.collect{|s| s.observation_duration}.sum
    dashboards = all_sessions.collect{|s| s.itl_summary_strategies}.flatten.select{ |d| d.tl_activity_type_task_id == self.id}
    task_duration = dashboards.collect{|d| d.duration}.compact.sum
    involve_score = dashboards.collect{|d| d.engage_total}.compact.sum
    involve_count = dashboards.collect{|d| d.engage_segments}.compact.sum
    avg_involve = involve_count == 0 ? nil : involve_score.to_f/involve_count.to_f
    impact_total = dashboards.empty? ? 0 : dashboards.collect{|s| s.tl_activity_type_task.research * s.segments}.sum
    avg_impact = dashboards.empty? ? 0 : (impact_total.to_f/dashboards.collect{|s| s.segments}.sum.to_f).round.to_i
    pct_duration = sessions_duration == 0 ? 0 : (100*task_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (task_duration.to_f/num_sessions.to_f).round.to_i  
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, task_duration]
  end

  def stats_for_subject_org_between(subject, organization, start_date, end_date )

    all_sessions = TltSession.find(:all, :conditions =>["subject_area_id =? AND session_date >= ? AND session_date <= ? AND organization_id = ? AND is_final", subject.id, start_date, end_date, organization.id])
    num_sessions = all_sessions.size
    dashboards = all_sessions.collect{|s| s.tlt_dashboards}.flatten.select{ |d| d.tl_activity_type_task_id == self.id}
    sessions_duration = all_sessions.collect{|s| s.session_length}.sum
    task_duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    involve_score = dashboards.collect{|d| d.involve_total}.compact.sum
    involve_count = dashboards.collect{|d| d.involve_count}.compact.sum
    impact_score = dashboards.collect{|d| d.impact_total}.compact.sum
    impact_count = dashboards.collect{|d| d.impact_count}.compact.sum
    avg_involve = involve_count == 0 ? 0 : involve_score.to_f/involve_count.to_f
    avg_impact = impact_count == 0 ? 0 : impact_score.to_f/impact_count.to_f
    pct_duration = sessions_duration == 0 ? 0 : (100*task_duration.to_f/sessions_duration.to_f).round.to_i
    avg_duration = num_sessions == 0 ? 0 : (task_duration.to_f/num_sessions.to_f).round.to_i 
    stats = [avg_duration, pct_duration, avg_involve, avg_impact, dashboards.size, sessions_duration, task_duration]
  end

  def stats_for_subject_since(subject, since, org_type_id )

    all_dashboards = TltDashboard.find(:all, :conditions =>["subject_area_id =? AND created_at >= ?", subject.id, since]).select{|d| d.organization.organization_type_id == org_type_id}    
    dashboards = TltDashboard.find(:all, :conditions =>["tl_activity_type_task_id = ? AND subject_area_id =?  AND created_at >= ?", self.id, subject.id, since]).select{|d| d.organization.organization_type_id == org_type_id}           
    total_duration = all_dashboards.collect{|d| d.duration_secs}.compact.sum
    duration = dashboards.collect{|d| d.duration_secs}.compact.sum
    num_sessions = dashboards.collect{|d| d.tlt_session_id}.uniq.size
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
    dashboards = TltDashboard.find(:all, :conditions =>["tl_activity_type_task_id = ? AND user_id =?  AND created_at >= ?", self.id, user.id, since])       
    total_duration = all_dashboards.collect{|d| d.duration_secs}.compact.sum
    num_sessions = dashboards.collect{|d| d.tlt_session_id}.uniq.size
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

  def stats_for_user_subject_since(user, subject, since )

    all_dashboards = TltDashboard.find(:all, :conditions =>["user_id =? AND subject_area_id =? AND created_at >= ?", user.id, subject.id, since])
    dashboards = TltDashboard.find(:all, :conditions =>["tl_activity_type_task_id = ? AND user_id =? AND subject_area_id =? AND created_at >= ?", self.id, user.id, subject.id, since])       
    total_duration = all_dashboards.collect{|d| d.duration_secs}.compact.sum
    num_sessions = dashboards.collect{|d| d.tlt_session_id}.uniq.size
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

end
