class Ifa::SubmissionController <  Ifa::ApplicationController

    layout "ifa_submission"

    before_filter :current_classroom
    before_filter :current_app_superuser
    before_filter :current_user_app_admin
    before_filter :classroom_authorized?, :except=>[]
    before_filter :current_subject, :except => []
    before_filter :clear_notification, :except => []
    before_filter :provider_options, :except => []


    def index
      current_student_plan
      @last_submission = @current_user.act_submissions.for_subject(@current_subject).empty? ? nil : @current_user.act_submissions.for_subject(@current_subject).last
      @suggested_topics = @current_student_plan.nil? ? [] : @current_student_plan.classroom_lus(@current_classroom)

      @assessment_subjects = @current_user.act_submissions.collect{|s| s.act_subject}.uniq rescue []
      @dashboard_subjects = @current_user.ifa_dashboards.collect{|s| s.act_subject}.compact.uniq rescue []
      start_date = @current_provider.ifa_org_option.begin_school_year
      prepare_ifa_dashboard(@current_user, start_date, Date.today)
      @classroom_assessment_list = @current_classroom.act_assessments.active rescue []
      @success = true
      student_assessment_dashboard(@last_submission)
      assessment_header_info(@last_submission, ActMaster.default_std)
      user_ifa_plans
      find_dashboard_update_start_dates(@current_user)
    end


    def submit_assessment
      get_current_assessment
      if params[:function]=="Assess"
        @teacher_list = @current_classroom.teachers_for_student(@current_user).sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}
        if @teacher_list.size == 1
          @teacher = @teacher_list.first
        end
        @classroom_name = @current_classroom.course_name.upcase
        @student_name = @current_user.full_name.upcase
        if @current_user.picture.url.split("/").last == "missing.png"
          @student_pic = false
        else
          @student_pic = true
        end
        @preview = false
        @begin_time = Time.now
      else
        @teacher_list = []
        @classroom_name = "Course Name Will Be Displayed Here"
        @student_pic = false
        @student_name = "Student's Full Name"
        @preview = true
      end

      render :layout => "act_assessment"
    end


    def take_assessment
      initialize_parameters
      @ifa_classroom = @current_classroom
      @current_subject = @current_classroom.act_subject
      @last_submission = @current_user.act_submissions.for_subject(@current_subject).empty? ? nil : @current_user.act_submissions.for_subject(@current_subject).last
      @current_student_plan = @current_user.ifa_plan_for(@current_subject)
      @suggested_topics = @current_student_plan.nil? ? [] : @current_student_plan.classroom_lus(@current_classroom)

      @assessment_subjects = @current_user.act_submissions.collect{|s| s.act_subject}.uniq rescue []
      @dashboard_subjects = @current_user.ifa_dashboards.collect{|s| s.act_subject}.compact.uniq rescue []
      start_date = @current_provider.ifa_org_option.begin_school_year
      prepare_ifa_dashboard(@current_user, start_date, Date.today)
#    @current_student_dashboards = @current_user.ifa_dashboards.for_subject_since(@current_classroom.act_subject,(@current_provider.ifa_org_option.begin_school_year - 1.years)).reverse
      @classroom_assessment_list = @current_classroom.act_assessments.active.lock rescue []

#  @suggested_topics = @current_classroom.topics.select{|t| t.act_score_ranges.for_standard(@current_standard).first.upper_score >= @current_sms && t.act_score_ranges.for_standard(@current_standard).first.lower_score <= @current_sms}rescue nil

      if params[:function] == "Success"
        @success = true
      end
      @success = true
      student_assessment_dashboard(@last_submission)
      assessment_header_info(@last_submission, ActMaster.default_std)
      user_ifa_plans
      find_dashboard_update_start_dates(@current_user)
    end

  private

  def get_current_assessment
    if params[:act_assessment_id]
      @current_assessment = ActAssessment.find_by_id(params[:act_assessment_id]) rescue nil
    end
  end

  def current_student_plan
    @current_student_plan = @current_user.ifa_plan_for(@current_subject)
  end

  def user_ifa_plans
    @user_plans = {}
    ActSubject.plannable.each do |subject|
      if !@current_user.ifa_plan_subject(subject).nil?
        @user_plans[subject] = @current_user.ifa_plan_subject(subject)
      end
    end
  end

  #####    OLD Stuff Below

    def provider_options
      @options = @current_provider.ifa_org_option rescue nil
      initialize_ifa_user
    end

    def initialize_ifa_user
      if !@current_user.ifa_user_option
        user_option = IfaUserOption.new
        user_option.is_calibrated = false
        user_option.is_user_filtered = true
        user_option.is_org_filtered = false
        user_option.is_classroom_filtered = false
        user_option.is_colleague_filtered = false
        user_option.is_student_filtered = false
        user_option.beginning_period = @current_provider.ifa_org_option.begin_school_year
        user_option.act_master_id = @current_provider.master_standard
        @current_user.ifa_user_option = user_option
      end
    end

    def prepare_ifa_dashboard(entity, start_period, end_period)
      @entity = entity
      @start_period = start_period.to_date
      @end_period = end_period.to_date
      calibration_filter = @current_user.calibrated_only
      # @dashboards = IfaDashboard.find(:all, :conditions => ["act_subject_id = ? && ifa_dashboardable_id = ? && ifa_dashboardable_type = ? && period_end >= ? && period_end <= ?", @current_subject.id, entity.id, entity.class.to_s, start_period, end_period.end_of_month],:order=> "period_end ASC") rescue nil
      @dashboards = entity.ifa_dashboards.for_subject_between(@current_subject, start_period, end_period.end_of_month)

      if @dashboards then
        score_list = @dashboards.collect{|d| d.ifa_dashboard_sms_scores}.flatten.select{|s| s.act_master_id == @current_standard.id} rescue nil
        latest_dashboard_scores = @dashboards.last.ifa_dashboard_sms_scores.for_standard(@current_standard).first rescue nil
        @total_taken = @dashboards.collect{|d| d.assessments_taken}.sum
        @total_assessments = calibration_filter ? @dashboards.collect{|d| d.calibrated_assessments}.sum : @dashboards.collect{|d| d.finalized_assessments}.sum
        @total_answers = calibration_filter ? @dashboards.collect{|d| d.calibrated_answers}.sum : @dashboards.collect{|d| d.finalized_answers}.sum
        cal_submission_points = @dashboards.collect{|d| d.cal_submission_points}.sum
        @total_points = calibration_filter ? @dashboards.collect{|d| d.cal_points}.sum : @dashboards.collect{|d| d.fin_points}.sum
        @total_duration = calibration_filter ? @dashboards.collect{|d| d.calibrated_duration}.sum : @dashboards.collect{|d| d.finalized_duration}.sum
        @total_proficiency =  @total_answers == 0 ? 0 : (100*@total_points.to_f/@total_answers.to_f).round
        duration_points = calibration_filter ? cal_submission_points : @total_points
        @total_efficiency =  duration_points == 0 ? 0 : (@total_duration.to_f/duration_points.to_f).round
      end

      @current_sms_f = latest_dashboard_scores.sms_finalized rescue ""
      @current_sms_f = (@current_user.sat_view? && @current_sms_f != "") ? ActScoreRange.sat_score(@current_standard, @current_subject, @current_sms_f) : @current_sms_f
      @current_sms_c = latest_dashboard_scores.sms_calibrated rescue ""
      @current_sms_c = (@current_user.sat_view? && @current_sms_c != "") ? ActScoreRange.sat_score(@current_standard, @current_subject, @current_sms_c) : @current_sms_c
      @baseline_score = latest_dashboard_scores.baseline_score rescue nil

      @min_range = score_list ? score_list.collect{|sl| sl.score_range_min}.min : 0
      @max_range = score_list ? score_list.collect{|sl| sl.score_range_max}.max : 0

      @full_range_list = ActScoreRange.no_na.for_standard_and_subject(@current_standard, @current_subject) rescue []
      @range_list = @full_range_list.select{|r| @min_range <= r.upper_score && @max_range >= r.lower_score} rescue []

      @range_answers = []
      @range_points = []
      @range_pct = []
      @strand_list = ActStandard.for_standard_and_subject(@current_standard, @current_subject) rescue []
      @range_list.each_with_index do |r,rdx|
        @range_answers[rdx] = []
        @range_points[rdx] = []
        @strand_list.each_with_index do |s,sdx|
          sdx_answers = 0
          sdx_points = 0
          unless @dashboards.nil?
            @dashboards.each do |db|
              cell_stats = db.ifa_dashboard_cells.for_range_and_strand(r, s).first rescue nil
              if cell_stats
                sdx_answers += calibration_filter ? cell_stats.calibrated_answers : cell_stats.finalized_answers
                sdx_points += calibration_filter ? cell_stats.cal_points : cell_stats.fin_points
              end  # Cell Stats Present
            end # Dashboard for each period
          end
# Load stats for cell
          @range_answers[rdx] << sdx_answers
          @range_points[rdx] << sdx_points
        end   # End Strand Column
      end # End Range Row
    end


    def find_dashboard_update_start_dates(entity)
      if entity.class.to_s == "User"
        first_sub_for_update = entity.act_submissions.select{|s| !s.is_user_dashboarded}.sort{|a,b| a.created_at <=> b.created_at}.first rescue nil
        @start_date_user = first_sub_for_update ? first_sub_for_update.created_at : nil
        @months_back_user = @start_date_user ? (Date.today.month - @start_date_user.month) : nil
        @requester = "Student"
      end
      if entity.class.to_s == "Classroom"
        first_sub_for_update = entity.act_submissions.select{|s| !s.is_user_dashboarded}.sort{|a,b| a.created_at <=> b.created_at}.first rescue nil
        @start_date_user = first_sub_for_update ? first_sub_for_update.created_at : nil
        @months_back_user = @start_date_user ? (Date.today.month - @start_date_user.month) : nil
        first_sub_for_update = entity.act_submissions.select{|s| !s.is_classroom_dashboarded}.sort{|a,b| a.created_at <=> b.created_at}.first rescue nil
        @start_date_classroom = first_sub_for_update ? first_sub_for_update.created_at : nil
        @months_back_classroom = @start_date_classroom ? (Date.today.month - @start_date_classroom.month) : nil
        @requester = "Teacher"
      end
      if entity.class.to_s == "Organization"
        first_sub_for_update = entity.act_submissions.select{|s| !s.is_user_dashboarded}.sort{|a,b| a.created_at <=> b.created_at}.first rescue nil
        @start_date_user = first_sub_for_update ? first_sub_for_update.created_at : nil
        @months_back_user = @start_date_user ? (Date.today.month - @start_date_user.month) : nil
        first_sub_for_update = entity.act_submissions.select{|s| !s.is_classroom_dashboarded}.sort{|a,b| a.created_at <=> b.created_at}.first rescue nil
        @start_date_classroom = first_sub_for_update ? first_sub_for_update.created_at : nil
        @months_back_classroom = @start_date_classroom ? (Date.today.month - @start_date_classroom.month) : nil
        first_sub_for_update = entity.act_submissions.select{|s| !s.is_org_dashboarded}.sort{|a,b| a.created_at <=> b.created_at}.first rescue nil
        @start_date_org = first_sub_for_update ? first_sub_for_update.created_at : nil
        @months_back_org = @start_date_org ? (Date.today.month - @start_date_org.month) : nil
        @requester = "Admin"
      end
    end
end
