class Ifa::IfaDashboardController < Ifa::ApplicationController

  layout "ifa", :only=>[]


  def growth_dashboards  # used by 'student_history' partial which appears to be inactive.
    get_subject
    get_entity
    @submission_months = @entity.act_submissions.final_for_subject_since(@current_subject, @current_ifa_options.begin_school_year).collect{|s| s.date_finalized.beginning_of_month}.uniq.sort_by{ |d| d }.reverse
  end

  def entity_subject_dashboards
    current_subject
    get_entity
    @entity_dashboards = @entity.ifa_dashboards.for_subject(@current_subject).by_date
  end

  def entity_dashboard
    get_subject
    get_dashboard
    get_current_plan(@current_subject)
    dashboard_cell_hashes(@entity_dashboard, @current_subject, @current_standard)
    dashboard_header_info(@entity_dashboard, @current_subject, @current_standard)
    dashboardable_submissions(@entity_dashboard, @current_subject )
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

end
