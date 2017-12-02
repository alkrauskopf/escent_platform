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
    dashboardable_submissions_notice
    aggregate_dashboard_header_info(@organization_dashboards, @current_subject, @current_standard, @current_organization)
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
    aggregate_dashboard_header_info(@dashboards, @current_subject, @current_standard, @entity)

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
    dashboard_header_info(@entity_dashboard, @current_subject, @current_standard)
    dashboard_plan_markers(dashboard_users(@entity_dashboard), @current_subject, @current_standard)
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
    dashboard_header_info(@entity_dashboard, @current_subject, @current_standard)
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

  private

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
    if params[:entity_class] == 'Organization'
      @entity =  Organization.find_by_public_id(params[:entity_id])
    elsif params[:entity_class] == 'Classroom'
      @entity =  Classroom.find_by_public_id(params[:entity_id])
    elsif params[:entity_class] == 'User'
      @entity =  User.find_by_public_id(params[:entity_id])
    else
      @entity = nil
    end
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
end
