class AppMaintenance::IfaDashboardController < AppMaintenance::ApplicationController

    layout "ifa_maint", :except =>[]

    before_filter :set_ifa, :except=>[]
    before_filter :current_org_current_app_provider?, :except=>[]
    before_filter :current_user_app_superuser?, :except => []
    before_filter :clear_notification, :except => []
    before_filter :current_standard, :except => []
    before_filter :current_subject, :except => []
    before_filter :subjects, :except => []
    before_filter :current_ifa_options
    before_filter :prep_classrooms

    def index
      dashboard_entities
      submission_entities
    end

    def subject_select
      dashboard_entities
      submission_entities
      render :partial =>  "manage_dashboards", :locals=>{}
    end

    def dashboard_entity_select
      get_current_entity
      dashboard_entities
      render :partial =>  "entity_dashboard_list", :locals => {:entity_class => params[:entity_class]}
    end

    def submission_entity_select
      get_current_entity
      submission_entities
      entity_submissions
      render :partial =>  "entity_submissions_list", :locals => {:entity_class => params[:entity_class]}
    end

    def submission_period_analyze
      get_current_entity
      get_current_period
      submission_entities
      render :partial =>  "entity_submission_period_analyze", :locals => {:entity_class => params[:entity_class]}
    end

    def submissions_redash
      get_current_entity
      get_current_period
      current_period_submissions.each do |sub|
        if sub.final?
          sub.auto_ifa_dashboard_update_new(@current_entity, @current_standard)
        end
      end
      render :partial => 'entity_submission_period_summary', :locals => {:period => @current_period, :current_submission_list => current_period_submissions,
                                                                         :current_entity => @current_entity,
                                                                          :current_dashboards => current_period_dashboards}
    end

    def submissions_dashboardable_reset
      get_current_entity
      get_current_period
      if !current_period_dashboards.empty?
        current_period_dashboards.destroy_all
      end
      current_period_submissions.each do |sub|
        sub.set_dashboardable(@current_entity, false)
      end
      render :partial => 'entity_submission_period_summary', :locals => {:period => @current_period, :current_submission_list => current_period_submissions,
                                                                         :current_entity => @current_entity,
                                                                         :current_dashboards => current_period_dashboards}
    end

    def analyze
      current_dashboard
      render :partial => 'entity_dashboard_analyze', :locals => {:dashboard => @current_dashboard, :analyze => true}
    end

    def redash
      current_dashboard
      flash[:notice] = "Dashboard Re-Dashed"
      render :partial => 'entity_dashboard_analyze', :locals => {:dashboard => @current_dashboard, :analyze => false}
    end


    def destroy
      current_dashboard
      @current_entity = @current_dashboard.ifa_dashboardable
     # @current_dashboard.destroy
      flash[:notice] = "Dashboard Destroyed"
      entity_list
      render :partial => 'entity_dashboard_analyze', :locals => {:dashboard => nil, :analyze => false}
    end

  private

    def get_current_entity
      if params[:entity_class] == 'User'
        @current_entity = User.find_by_id(params[:entity_id])
      elsif params[:entity_class] == 'Classroom'
        @current_entity = Classroom.find_by_id(params[:entity_id])
      elsif params[:entity_class] == 'Organization'
        @current_entity = Organization.find_by_id(params[:entity_id])
      else
        @current_entity = nil
      end
    end

    def get_current_period
      @current_period = Date.parse(params[:period])
    end

    def dashboard_entities
      @entities = {}
      @entities['User'] = @current_subject.ifa_dashboards.for_entity_class('User').map{|d| d.entity}.compact.uniq.sort_by{|e| e.name}
      @entities['Classroom'] = @current_subject.ifa_dashboards.for_entity_class('Classroom').map{|d| d.entity}.compact.uniq.sort_by{|e| e.name}
      @entities['Organization'] = @current_subject.ifa_dashboards.for_entity_class('Organization').map{|d| d.entity}.compact.uniq.sort_by{|e| e.name}
    end

    def submission_entities
      @submission_entities = {}
      @submission_entities['User'] = @current_subject.act_submissions.user_list_final
      @submission_entities['Classroom'] = @current_subject.act_submissions.classroom_list_final
      @submission_entities['Organization'] = @current_subject.act_submissions.organization_list_final
    end

    def entity_submissions
      @current_entity_submissions = {}
      @current_entity_dashboards = {}
      @current_submission_periods = @current_entity.act_submissions.for_subject(@current_subject).month_periods
      @current_submission_periods.each do |period|
        @current_entity_submissions[period] =  @current_entity.act_submissions.for_subject(@current_subject).submission_period(period.beginning_of_month, period.end_of_month)
        @current_entity_dashboards[period] = @current_entity.ifa_dashboards.for_subject(@current_subject).for_period(period)
      end
    end

    def current_period_submissions
      if @current_entity && @current_subject && @current_period
        submissions = @current_entity.act_submissions.for_subject(@current_subject).submission_period(@current_period.beginning_of_month, @current_period.end_of_month)
      else
        submissions = []
      end
      submissions
    end

    def reset_submission_dashboardable

    end

    def current_period_dashboards
      if @current_entity && @current_subject && @current_period
        dashboards = @current_entity.ifa_dashboards.for_subject(@current_subject).for_period(@current_period)
      else
        dashboards = []
      end
      dashboards
      end

    def current_standard
      if params[:act_master_id]
        @current_standard = ActMaster.find_by_id(params[:act_master_id])
      else
        @current_standard = @current_provider.master_standard
      end
    end

    def current_dashboard
      if params[:ifa_dashboard_id]
        @current_dashboard = IfaDashboard.find_by_id(params[:ifa_dashboard_id])
      else
        @current_dashboard = nil
      end
    end

    def current_subject
      if params[:act_subject_id]
        @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
      else
        @current_subject = ActSubject.first
      end
    end

    def standards
      @standards = ActMaster.all
    end

    def strands
      @strands = ActStandard.all_for_standard_and_subject(@current_standard, @current_subject)
    end

    def levels
      @levels = ActScoreRange.all_for_standard_and_subject(@current_standard, @current_subject)
    end

    def subjects
      @subjects = ActSubject.all
    end

    def prep_classrooms
      @prep_classrooms = @current_subject.nil? ? [] : @current_subject.classrooms.precision_prep_provider(@current_organization)
    end

    def current_strand
      if !@strands.empty?
        get_strand
        @current_strand = @current_strand.nil? ? @strands.first : @current_strand
      else
        @current_strand = nil
      end
    end

    def get_strand
      if params[:act_standard_id]
        @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
      else
        @current_strand = nil
      end
    end

    def get_classroom
      if params[:classroom_id]
        @current_classroom = Classroom.find_by_id(params[:classroom_id]) rescue nil
      else
        @current_classroom = nil
      end
    end

    def get_student
      if params[:user_id]
        @current_student = User.find_by_id(params[:user_id]) rescue nil
      else
        @current_student = nil
      end
    end

    def get_period
      if params[:period_end]
        @current_period = Date.parse(params[:period_end])
      elsif params[:dashboard] && params[:dashboard]['period(1i)'] && params[:dashboard]['period(2i)']
        @current_period = Date.new(params[:dashboard]['period(1i)'].to_i, params[:dashboard]['period(2i)'].to_i).end_of_month
      else
        @current_period = Date.today
      end
    end

    def get_dashboard
      if !@current_subject.nil? && !@current_period.nil? && !@current_student.nil?
        @current_dashboard = @current_student.ifa_dashboards.for_subject(@current_subject).for_period(@current_period).first rescue nil
      else
        @current_dashboard = nil
      end
    end
end
