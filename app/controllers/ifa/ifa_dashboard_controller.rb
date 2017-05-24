class Ifa::IfaDashboardController < Ifa::ApplicationController

  layout "ifa", :only=>[]

  def growth_dashboards
    get_subject
    get_entity
    @submission_months = @entity.act_submissions.final_for_subject_since(@subject, @current_ifa_options.begin_school_year).collect{|s| s.date_finalized.beginning_of_month}.uniq.sort_by{ |d| d }.reverse
  end

  def entity_dashboard
    get_subject
    get_entity
    get_current_plan(@subject)
    @begin_date = params[:begin_date].to_date
    @end_date = @begin_date.end_of_month
    entity_assessment_dashboard(@entity, @subject, @begin_date, @end_date)
  end

  private

  def get_subject
    @subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
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
    if !@entity.nil? && @entity.class.to_s == 'User'
      @current_student_plan = @entity.ifa_plan_for(subject)
    else
      @current_student_plan = nil
    end
  end

end
