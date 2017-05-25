class Ifa::IfaDashboardController < Ifa::ApplicationController

  layout "ifa", :only=>[]

  def growth_dashboards
    get_subject
    get_entity
    @submission_months = @entity.act_submissions.final_for_subject_since(@current_subject, @current_ifa_options.begin_school_year).collect{|s| s.date_finalized.beginning_of_month}.uniq.sort_by{ |d| d }.reverse
  end

  def entity_dashboard
    get_subject
    get_dashboard
    get_current_plan(@current_subject)
    dashboard_cell_hashes(@entity_dashboard, @current_subject, @current_standard)
    dashboard_header_info(@entity_dashboard, @current_subject, @current_standard)
  end

  private

  def get_subject
    @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
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
