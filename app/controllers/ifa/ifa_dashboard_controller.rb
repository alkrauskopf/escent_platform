class Ifa::IfaDashboardController < Ifa::ApplicationController

  layout "ifa", :except=>[:entity_subject_dashboards, :entity_dashboard]


  def index
    get_subject
    current_organization_dashboards
    classroom_list
    classroom_dashboards(@classroom_list)
    student_list
    student_dashboards(@student_list)
    org_list
    org_dashboards(@org_list)
    entity_strategies(@current_organization)
    dashboardable_submissions_notice
    aggregate_header_info(@organization_dashboards, @current_subject, @current_standard, @current_organization)
  #  aggregate_dashboard_header_info(@organization_dashboards, @current_subject, @current_standard, @current_organization)
  end

  def strategy_entity
    get_subject
    get_entity
    classroom_list
    student_list
    org_list
    entity_strategies(@entity)
    render :partial => "/ifa/ifa_dashboard/strategies", :locals=>{:organization=>@current_organization, :subject => @current_subject}
  end

  def strategy_entity_details
    get_subject
    get_strategy
    get_entity
    entity_strategy_details(@entity, @current_strategy)
    render :partial => "/ifa/ifa_dashboard/strategy_row", :locals=>{:strategy => @current_strategy, :entity => @entity, :subject=>@current_subject, :details=> (params[:details] == 'Y' ? 'N' : 'Y')}
  end

  def dashboard_submissions_process
    get_subject
    dashboardable_submissions_notice
    org_dashboardables(@current_subject)
    render :partial  => "ifa/ifa_dashboard/dashboardables"
  end

  def window_dashboard
    get_subject
    get_entity
    start_date = Date.new(params[:start_yr].to_i, params[:start_mth].to_i, 1)
    end_date = Date.new(params[:end_yr].to_i, params[:end_mth].to_i, 1).end_of_month
    @dashboards = @entity.ifa_dashboards.subject_between_periods(@current_subject, start_date, end_date)
    aggregate_dashboard_cell_hashes(@dashboards, @current_subject, @current_standard)
    aggregate_header_info(@dashboards, @current_subject, @current_standard, @entity)
 #   aggregate_dashboard_header_info(@dashboards, @current_subject, @current_standard, @entity)

    render :partial => "ifa/ifa_dashboard/dashboard",
           :locals=>{:dashboard => @entity, :subject => @current_subject, :standard=>@current_standard, :cell_corrects=>@cell_correct,
                     :cell_totals=>@cell_total, :cell_pcts=>@cell_pct, :cell_color=>@cell_color, :cell_font=>@cell_font}
  end

  def growth_dashboards  # used by 'student_history' partial which appears to be inactive.
    get_subject
    get_entity
    @submission_months = @entity.act_submissions.final_for_subject_since(@current_subject, @current_ifa_options.begin_school_year).collect{|s| s.date_finalized.beginning_of_month}.uniq.sort_by{ |d| d }.reverse
  end

  def entity_subject_dashboards
    get_subject
    get_entity
    entity_dashboards(@entity, @current_subject)
    @entity_dashboards = @entity.ifa_dashboards.for_subject(@current_subject).by_date
  end

  def entity_dashboard
    get_subject
    get_dashboard
    get_current_plan(@current_subject)
    student_view = @current_user.teacher? ? 'N':'Y'
    dashboard_cell_hashes(@entity_dashboard, @current_subject, @current_standard, :student => student_view )
 #   dashboard_header_info(@entity_dashboard, @current_subject, @current_standard)
    entity_header_info(@entity_dashboard, @current_subject, @current_standard)
    dashboard_plan_markers(@entity_dashboard, @current_subject, @current_standard)
 #   dashboard_plan_markers_old(dashboard_users(@entity_dashboard), @current_subject, @current_standard)
  end

  def dashboard_submissions
    get_entity
    get_subject
    get_dashboard
    unless @entity.nil?
      ActSubmission.not_dashboarded(@entity.class.to_s, @entity, @current_subject, @entity_dashboard.period_beginning, @entity_dashboard.period_ending).each do |submission|
        if @entity.class.to_s == 'User'
          submission.dashboard_it(submission.user)
        elsif @entity.class.to_s == 'Classroom'
          submission.dashboard_it(submission.classroom)
        elsif @entity.class.to_s == 'Organization'
          submission.dashboard_it(submission.organization)
        end
      end
    end
    get_dashboard
    dashboard_cell_hashes(@entity_dashboard, @current_subject, @current_standard)
    entity_header_info(@entity_dashboard, @current_subject, @current_standard)
#    dashboard_header_info(@entity_dashboard, @current_subject, @current_standard)
    dashboardable_submissions(@entity_dashboard, @current_subject )
    render :partial => "ifa/ifa_dashboard/dashboard",
        :locals=>{:dashboard => @entity_dashboard, :subject => @current_subject, :standard => @current_user.standard_view, :cell_corrects=>@cell_correct,
                  :cell_totals=>@cell_total, :cell_pcts=>@cell_pct, :cell_color=>@cell_color, :cell_font=>@cell_font}
  end

  def dashboard_entity_submissions
    get_entity
    get_subject
    dashboardables_for(@entity, @current_subject).each do |submission|
      if @entity.class.to_s == 'User'
        submission.auto_ifa_dashboard_update_new(submission.user, @current_standard)
      elsif @entity.class.to_s == 'Classroom'
        if submission.act_subject_id == submission.classroom.act_subject.id
          submission.auto_ifa_dashboard_update_new(submission.classroom, @current_standard)
        end
      elsif @entity.class.to_s == 'Organization'
        submission.auto_ifa_dashboard_update_new(submission.organization, @current_standard)
      end
    end
    dashboardable_submissions_notice
    org_dashboardables(@current_subject)
    render :partial  => "ifa/ifa_dashboard/dashboardables"
  end

  def dashboard_marker_refresh
    get_entity
    get_subject
    IfaPlanMetric.reinitialize(@entity, @current_subject, @current_standard)
    render :partial => "/ifa/ifa_dashboard/plan_marker_refresh", :locals=>{:subject=>@current_subject, :entity=>@entity}
  end

  def dashboard_marker_refresh_all
    get_subject
    if entity_class == 'Organization'
      @entity_list = []
      @entity_list << @current_organization
    elsif entity_class == 'Classroom'
      @entity_list = @current_organization.classrooms.ifa_enabled_subject(@current_subject)
    elsif entity_class == 'User'
      @entity_list = @current_organization.classrooms.ifa_students_subject(@current_subject)
    else
      @entity_list = []
    end
    @entity_list.each do |entity|
      IfaPlanMetric.reinitialize(entity, @current_subject, @current_standard)
    end
    render :partial => "/ifa/ifa_dashboard/plan_marker_refresh_all", :locals=>{:subject=>@current_subject, :entity_class=>entity_class}
  end

  private

  def get_strategy
    @current_strategy = ActStrategy.find_by_id(params[:act_strategy_id]) rescue nil
  end

  def get_subject
    @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
  end

  def current_subject
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
  end

  def get_dashboard
    @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
  end

  def get_entity
    if entity_class == 'Organization'
      @entity =  Organization.find_by_public_id(params[:entity_id])
    elsif entity_class == 'Classroom'
      @entity =  Classroom.find_by_public_id(params[:entity_id])
    elsif entity_class == 'User'
      @entity =  User.find_by_public_id(params[:entity_id])
    else
      @entity = nil
    end
  end

  def entity_class
    params[:entity_class]
  end

  def get_current_plan(subject)
    if !@entity_dashboard.nil? && @entity_dashboard.ifa_dashboardable_type == "User" && !@entity_dashboard.ifa_dashboardable.nil?
      @current_student_plan = @entity_dashboard.ifa_dashboardable.ifa_plan_for(subject)
    else
      @current_student_plan = nil
    end
  end

  def current_organization_dashboards
    @organization_dashboards = @current_organization.ifa_dashboards.for_subject(@current_subject) rescue []
  end

  def classroom_list
    @classroom_list =(@current_provider == @current_organization) ? @current_organization.precision_prep_provider_classrooms(@current_subject)
    : @current_organization.classrooms.ifa_enabled_subject(@current_subject).sort{|a,b| a.course_name <=> b.course_name}
  end

  def classroom_dashboards(classrooms)
    @classroom_dashboards = {}
    @classroom_list_label = {}
    @classroom_dashboards['name'] = ((@current_provider == @current_organization) ? @current_application.app_name(:provider=>@current_provider)
    : (@current_organization.short_name)) + ', ' + @current_subject.name
    classrooms.each do |classroom|
      @classroom_dashboards[classroom.id] = classroom.ifa_dashboards.for_subject(@current_subject).reverse
      @classroom_list_label[classroom.id] = @current_provider == @current_organization ? (' | ' + classroom.organization.short_name) : ''
    end
  end

  def student_list
    @student_list = (@current_provider == @current_organization) ? @current_organization.precision_prep_provider_subject_students(@current_subject)
    : @current_organization.classrooms.ifa_students_subject(@current_subject)
  end

  def student_dashboards(students)
    @student_dashboards = {}
    @student_list_label = {}
    @student_dashboards['name'] = ((@current_provider == @current_organization) ? @current_application.app_name(:provider=>@current_provider)
    : (@current_organization.short_name)) + ', ' + @current_subject.name
    students.each do |stud|
      @student_dashboards[stud.id] = stud.ifa_dashboards.for_subject(@current_subject).reverse
      @student_list_label[stud.id] = @current_provider == @current_organization ? (' | ' + stud.organization.short_name) : ''
    end
  end

  def org_list
    @org_list = (@current_provider == @current_organization) ? @current_provider.provided_app_orgs(@current_application, false)
    : Organization.siblings_of(@current_organization).active
  end

  def org_dashboards(orgs)
    @org_dashboards = {}
    @org_dashboards['name'] = ((@current_provider == @current_organization) ? @current_application.app_name(:provider=>@current_provider)
    : @current_organization.parent_or_self.name) + ', ' + @current_subject.name
    orgs.each do |org|
      @org_dashboards[org.id] = org.ifa_dashboards.for_subject(@current_subject).reverse
    end
  end

  def dashboardable_submissions_notice
    org_dashboardables = @current_organization.act_submissions.dashboardable('Organization', :subject=>@current_subject)
    classroom_dashboardables = @current_organization.act_submissions.dashboardable('Classroom', :subject=>@current_subject)
    @dashboardable_submissions_notice = (org_dashboardables.empty? && classroom_dashboardables.empty?) ? '' :
        @current_subject.name + ' submissions have not been dashboarded.'
  end

  def org_dashboardables(subject)
    @dashboardable_entities = []
    @dashboardable_counts = {}
    dashboardable_entity(@current_organization, subject)
    @current_organization.classrooms.ifa_enabled_subject(subject).each do |classroom|
      dashboardable_entity(classroom, subject)
    end
    @dashboardable_entities.compact
  end

  def dashboardable_entity(entity, subject)
    if !entity.nil? && !subject.nil?
      if entity.class.to_s == 'Organization' && !entity.act_submissions.for_subject(subject).final.not_org_dashboarded.empty?
        @dashboardable_entities <<  entity
        @dashboardable_counts[entity] = entity.act_submissions.for_subject(subject).final.not_org_dashboarded.size
      elsif entity.class.to_s == 'Classroom' && !entity.act_submissions.for_subject(subject).final.not_classroom_dashboarded.empty?
        @dashboardable_entities <<  entity
        @dashboardable_counts[entity] = entity.act_submissions.for_subject(subject).final.not_classroom_dashboarded.size
      elsif entity.class.to_s == 'User' && !entity.act_submissions.for_subject(subject).final.not_user_dashboarded.empty?
        @dashboardable_entities <<  entity
        @dashboardable_counts[entity] = entity.act_submissions.for_subject(subject).final.not_user_dashboarded.size
      end
    end
  end

  def dashboardables_for(entity, subject)
    submissions = []
    if !entity.nil? && !subject.nil?
      if entity.class.to_s == 'Organization'
        submissions =  entity.act_submissions.for_subject(subject).final.not_org_dashboarded
      elsif entity.class.to_s == 'Classroom'
        submissions =  entity.act_submissions.for_subject(subject).final.not_classroom_dashboarded
      elsif entity.class.to_s == 'User'
        submissions =  entity.act_submissions.for_subject(subject).final.not_user_dashboarded
      end
    end
    submissions
  end

  def entity_dashboards(entity, subject)
    @entity_dashboards = {}
    @entity_dashboards[subject] = entity.ifa_dashboards.for_subject(subject).by_date
  end

  def entity_strategies(entity)
    @entity_strategies = {}
    @entity_strategies['entity'] = entity
    @current_subject.active_strategies.each do |strategy|
      @entity_strategies[strategy.id.to_s + 'name'] = strategy.name
      @entity_strategies[strategy.id.to_s + 'ass_count'] = entity.act_strategy_logs.for_strategy(strategy).size
      @entity_strategies[strategy.id.to_s + 'quest_count'] = entity.act_strategy_logs.for_strategy(strategy).map{|sl| sl.act_assessment.nil? ? 0 : sl.act_assessment.act_questions.with_strategy(strategy).size}.sum
      @entity_strategies[strategy.id.to_s + 'prefers'] = entity.act_strategy_logs.for_strategy(strategy).map{|sl| sl.preferred}.sum
      @entity_strategies[strategy.id.to_s + 'matches'] = entity.act_strategy_logs.for_strategy(strategy).map{|sl| sl.matches}.sum
      @entity_strategies[strategy.id.to_s + 'mis_matches'] = entity.act_strategy_logs.for_strategy(strategy).map{|sl| sl.mis_matches}.sum
      @entity_strategies[strategy.id.to_s + 'correct'] = entity.act_strategy_logs.for_strategy(strategy).map{|sl| sl.corrects}.sum
      @entity_strategies[strategy.id.to_s + 'incorrect'] = entity.act_strategy_logs.for_strategy(strategy).map{|sl| sl.incorrects}.sum
      @entity_strategies[strategy.id.to_s + 'used'] = @entity_strategies[strategy.id.to_s + 'mis_matches'] + @entity_strategies[strategy.id.to_s + 'matches']
      @entity_strategies[strategy.id.to_s + 'match_pct'] = @entity_strategies[strategy.id.to_s + 'prefers'] == 0 ? 0 :
          (100.0 * @entity_strategies[strategy.id.to_s + 'matches'].to_f/@entity_strategies[strategy.id.to_s + 'prefers'].to_f).round
      @entity_strategies[strategy.id.to_s + 'mis_match_pct'] = @entity_strategies[strategy.id.to_s + 'prefers'] == 0 ? 0 :
          (100.0 * @entity_strategies[strategy.id.to_s + 'mis_matches'].to_f/@entity_strategies[strategy.id.to_s + 'prefers'].to_f).round
      @entity_strategies[strategy.id.to_s + 'tot_correct_pct'] = @entity_strategies[strategy.id.to_s + 'used'] == 0 ? 0 :
          (100.0 * @entity_strategies[strategy.id.to_s + 'correct'].to_f/@entity_strategies[strategy.id.to_s + 'used'].to_f).round
      @entity_strategies[strategy.id.to_s + 'tot_incorrect_pct'] = @entity_strategies[strategy.id.to_s + 'used'] == 0 ? 0 :
          (100.0 * @entity_strategies[strategy.id.to_s + 'incorrect'].to_f/@entity_strategies[strategy.id.to_s + 'used'].to_f).round
    end
  end

  def entity_strategy_details(entity, strategy)
    @entity_strategy_details = {}
    idx = 0
    if entity.class.to_s == 'User'
      entity.act_strategy_logs.for_strategy(strategy).each do |sub_log|
        @entity_strategy_details['row'+ idx.to_s + 'ass_date'] = sub_log.created_at.strftime("%b %d, %Y")
        @entity_strategy_details['row'+ idx.to_s + 'ass'] = sub_log.act_assessment.nil? ? 'Assessment Undefined' : sub_log.act_assessment.name
        strategy_questions = sub_log.act_assessment.nil? ? 0 : sub_log.act_assessment.act_questions.with_strategy(strategy).size
        @entity_strategy_details['row'+ idx.to_s + 'quest_count'] =  strategy_questions.to_s + (strategy_questions == 1 ? ' Question' : ' Questions') + ' for strategy'
        @entity_strategy_details['row'+ idx.to_s + 'match'] = sub_log.matches
        @entity_strategy_details['row'+ idx.to_s + 'mis_match'] = sub_log.mis_matches
        @entity_strategy_details['row'+ idx.to_s + 'used'] = @entity_strategy_details['row'+ idx.to_s + 'match'] + @entity_strategy_details['row'+ idx.to_s + 'mis_match']
        @entity_strategy_details['row'+ idx.to_s + 'correct'] = sub_log.corrects
        @entity_strategy_details['row'+ idx.to_s + 'incorrect'] = sub_log.incorrects
        idx += 1
      end
    else
      entity.act_strategy_logs.for_strategy(strategy).group_by{|sl| sl.period_end}.each do |sub_date, sub_logs|
        @entity_strategy_details['row'+ idx.to_s + 'ass_date'] = sub_date.strftime("%b %Y")
        @entity_strategy_details['row'+ idx.to_s + 'ass'] = sub_logs.size.to_s + (sub_logs.size == 1 ? ' Assessment' : ' Assessments')
        strategy_questions = sub_logs.map{|sl| sl.act_assessment.nil? ? 0 : sl.act_assessment.act_questions.with_strategy(strategy).size}.sum
        @entity_strategy_details['row'+ idx.to_s + 'quest_count'] =  strategy_questions.to_s + (strategy_questions == 1 ? ' Question' : ' Questions') + ' for strategy'
        @entity_strategy_details['row'+ idx.to_s + 'match'] = sub_logs.map{|sl| sl.matches}.sum
        @entity_strategy_details['row'+ idx.to_s + 'mis_match'] = sub_logs.map{|sl| sl.mis_matches}.sum
        @entity_strategy_details['row'+ idx.to_s + 'used'] = @entity_strategy_details['row'+ idx.to_s + 'match'] + @entity_strategy_details['row'+ idx.to_s + 'mis_match']
        @entity_strategy_details['row'+ idx.to_s + 'correct'] = sub_logs.map{|sl| sl.corrects}.sum
        @entity_strategy_details['row'+ idx.to_s + 'incorrect'] = sub_logs.map{|sl| sl.incorrects}.sum
        idx += 1
      end
    end
    @entity_strategy_details['row_count'] = idx
  end
end
