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
      entity_list

    end

    def subject_select
      entity_list
      render :partial =>  "manage_dashboards", :locals=>{}
    end

    def entity_select
      get_current_entity
      entity_list
      render :partial =>  "entity_dashboard_list", :locals => {:entity_class => params[:entity_class]}
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

    def entity_list
      @entities = {}
      @entities['User'] = @current_subject.ifa_dashboards.for_entity_class('User').map{|d| d.entity}.compact.uniq.sort_by{|e| e.name}
      @entities['Classroom'] = @current_subject.ifa_dashboards.for_entity_class('Classroom').map{|d| d.entity}.compact.uniq.sort_by{|e| e.name}
      @entities['Organization'] = @current_subject.ifa_dashboards.for_entity_class('Organization').map{|d| d.entity}.compact.uniq.sort_by{|e| e.name}
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

    def redashboard(dashboard)
      subject = dashboard.act_subject
      standard = @current_standard
      begin_date = dashboard.period_end.beginning_of_month
      end_date = dashboard.period_end
      submissions = dashboard.entity.act_submissions.for_subject(subject).submission_period(begin_date, end_date).final
      cal_submissions = submissions.select{|s| s.act_assessment.calibrate?}
      new_dashboard = IfaDashboard.new
      new_dashboard = dashboard.clone
      new_dashboard.assessments_taken = submissions.size
      new_dashboard.finalized_assessments = submissions.size
      new_dashboard.calibrated_assessments = cal_submissions.size
      new_dashboard.finalized_answers = submissions.map{|s| s.tot_choices}.sum
      new_dashboard.calibrated_answers = submissions.map{|s| s.cal_choices}.sum
      new_dashboard.finalized_duration = submissions.map{|s| s.duration}.sum
      new_dashboard.calibrated_duration = cal_submissions.map{|s| s.duration}.sum
      new_dashboard.fin_points = submissions.map{|s| s.tot_points}.sum
      new_dashboard.cal_points = submissions.map{|s| s.cal_points}.sum
      new_dashboard.cal_submission_points = cal_submissions.map{|s| s.cal_points}.sum
      new_dashboard.cal_submission_answers = cal_submissions.map{|s| s.cal_choices}.sum
      if new_dashboard.save
        standard.mastery_levels(subject).each do |level|
          standard.strands(subject).each do |strand|
            selected_answers = submissions.map{|s| s.act_answers.selected_level_strand(level,strand)}.flatten
            calibrated_answers = selected_answers.select{|a| a.is_calibrated}
            if !selected_answers.empty?
              dashboard_cell = IfaDashboardCell.new
              dashboard_cell.act_master_id = standard.id
              dashboard_cell.act_score_range_id = level.id
              dashboard_cell.act_standard_id = strand.id
              dashboard_cell.finalized_answers = selected_answers.size
              dashboard_cell.calibrated_answers = calibrated_answers.size
              dashboard_cell.fin_points = selected_answers.map{|a| a.points}.sum
              dashboard_cell.cal_points = calibrated_answers.map{|a| a.points}.sum
              new_dashboard.ifa_dashboard_cells << dashboard_cell
            end
          end
        end
        dashboard_score = IfaDashboardSmsScore.new
        dashboard_score.act_master_id = standard.id
        dashboard_score.score_range_min = new_dashboard.level_range(standard).first.lower_score rescue 0
        dashboard_score.score_range_max = new_dashboard.level_range(standard).last.upper_score rescue 0
        dashboard_score.standard_score = new_dashboard.calculated_standard_score(standard, :calibrated => false)
        dashboard_score.standard_score_cal = new_dashboard.calculated_standard_score(standard, :calibrated => true)
        dashboard_score.sms_finalized = standard.sms_for_dashboard(new_dashboard, :calibrated => false)
        dashboard_score.sms_calibrated = standard.sms_for_dashboard(new_dashboard, :calibrated => true)
        dashboard_score.baseline_score = standard.base_score(entity, self.act_subject)
        new_dashboard.ifa_dashboard_sms_scores << dashboard_score
        dashboard_sms.save

        dashboard.update_attributes(:is_replaced => true)
      end
    end
end
