class Ifa::SubmissionController <  Ifa::ApplicationController

    layout "ifa_submission"

    before_filter :current_classroom
    before_filter :current_user_classroom_period?, :only=>[:index]
    before_filter :current_user_classroom_teacher?, :only=>[:teacher_review]
    before_filter :current_app_superuser
    before_filter :current_user_app_admin
    before_filter :classroom_authorized?, :only=>[:index]
    before_filter :current_subject, :except => []
    before_filter :clear_notification, :except => [:index,:teacher_review]
    before_filter :provider_options, :except => []

    def index
      current_student_plan
      get_current_submission
      get_current_teacher
      assessment_pool_info
      @last_submission = !@current_submission.nil? ? @current_submission : (@current_user.act_submissions.for_subject(@current_subject).empty? ? nil : @current_user.act_submissions.for_subject(@current_subject).last)
      @suggested_topics = @current_student_plan.nil? ? [] : @current_student_plan.classroom_lus(@current_classroom)
      @assessment_subjects = @current_user.act_submissions.collect{|s| s.act_subject}.uniq rescue []
      @dashboard_subjects = @current_user.ifa_dashboards.collect{|s| s.act_subject}.compact.uniq rescue []
      entity_subject_dashboards(@current_user)
      start_date = @current_provider.ifa_org_option.begin_school_year
      prepare_ifa_dashboard(@current_user, start_date, Date.today)
      student_assessment_dashboard(@last_submission)
      assessment_header_info(@last_submission, @current_standard)
      user_ifa_plans
      find_dashboard_update_start_dates(@current_user)
      db_users = []
      db_users << @current_user
      dashboard_plan_markers(db_users, @current_subject, @current_standard)
    end

    def teacher_review
      classroom_submissions
      @assessment_subjects = @all_submitted_assessments.collect{|s| s.act_subject}.uniq rescue []
      classroom_periods_students
      @current_classroom_dashboards = @current_classroom.ifa_dashboards
      aggregate_dashboard_cell_hashes(@current_classroom_dashboards, @current_classroom.act_subject, @current_standard)
      aggregate_dashboard_header_info(@current_classroom_dashboards, @current_classroom.act_subject, @current_standard, @current_classroom)
      db_users = []
      db_users << @current_classroom.students
      dashboard_plan_markers(@current_classroom.students, @current_classroom.act_subject, @current_standard)
    end

    def review_student_dashboard
      get_current_student
      get_current_dashboard
      format_dashboard(@current_dashboard, @current_classroom.act_subject, @current_standard)
      dashboard_plan_markers(dashboard_users(@current_dashboard), @current_classroom.act_subject, @current_standard)
      render :partial =>  "teacher_period_student_dashboards", :locals=>{:period => @current_classroom_period,
                                                                         :student => @current_student,
                                                                         :dashboards => @current_student.dashboards(:subject => @current_classroom.act_subject),
                                                                         :dashboard => @current_dashboard}
    end

    def review_classroom_dashboard
      get_current_dashboard
      format_dashboard(@current_dashboard, @current_dashboard.act_subject, @current_standard)
      display_db = params[:display] == 'true' ? true:false
      dashboard_plan_markers(dashboard_users(@current_dashboard), @current_dashboard.act_subject, @current_standard)
      render :partial =>  "teacher_classroom_dashboard", :locals=>{:dashboard => @current_dashboard, :dashboard_display => display_db}
    end

    def destroy_pending
      get_current_submission
      if @current_submission
        @current_submission.destroy_it
      end
      classroom_submissions
      render :partial => "/ifa/submission/teacher_review_pending"
    end

    def destroy_all_pending
      classroom_submissions
      @pending_teacher_submissions.destroy_all
      classroom_submissions
      render :partial => "/ifa/submission/teacher_review_pending"
    end

    def take_assessment
      get_current_assessment
      get_current_teacher
      if params[:function]=="Assess"
        @preview = false
        @begin_time = Time.now
        @view_mode = 'Take'
      else
        @view_mode = 'Preview'
      end

      render :layout => "assessment"
    end

    def submission_teacher_select
      get_current_teacher
      assessment_pool_info
      render :partial => "list_classroom_assessments"
    end

    def submit_assessment
      get_current_assessment
      get_current_teacher
      if create_current_submission?
        if sa_answers_completed?
          if mc_answers_completed?
            score_submission
            if auto_finalize?
              @current_submission.finalize_new(true, @current_submission.teacher_id, @current_provider.master_standard)
            end
            if auto_notify?
              UserMailer.assessment_submission(@current_teacher, @current_user,@current_classroom,
                                               @current_organization, !auto_finalize?, request.host_with_port).deliver
            end
            submission_failed = false
            if submission_failed
              @current_submission.destroy_it
              flash[:error] = 'Assessment Destroyed'
            else
              flash[:notice] = 'Submitted'
            end
          else
            @current_submission.destroy_it
            flash[:error] = 'Problem With Multiple Choice Logging Assessment Destroyed'
          end
        else
          @current_submission.destroy_it
          flash[:error] = 'Problem With Short Answer Logging - Assessment Destroyed'
        end
      end
      redirect_to ifa_take_path(:organization_id => @current_organization, :classroom_id => @current_classroom.id,
                                :period_id => @current_classroom_period.id, :act_submission_is => (@current_submission.nil? ? nil : @current_submission.id),
                                :topic_id => (@current_topic.nil? ? nil : @current_topic.id))
    end

    def teacher_review_submission
      get_current_submission
      render 'review_assessment', :layout => "assessment"
    end

    def teacher_review_update
      get_current_submission
      if params[:commit] == 'Finalize' || params[:commit] == 'Save Only'
        if params[:act_submission]
          @current_submission.update_attributes(:teacher_comment => params[:act_submission][:teacher_comment], :reviewer_id => params[:reviewer_id])
        end
        if params[:question_id]
          sa_answers_review
        end
        if params[:commit] == 'Finalize'
          if @current_submission.finalize_new(false, params[:reviewer_id], @current_provider.master_standard)
            flash[:notice] = 'Assessment Finalized'
          else
            flash[:error] = "Problem Occurred WhileFinalizing Assessment"
          end
        else
          flash[:notice] = "Assessment Review Data Save, Not Finalized"
        end
      else
        flash[:notice] = "Assessment Review Cancelled"
      end
      redirect_to ifa_submission_teacher_review_path(:organization_id => @current_organization,:classroom_id => @current_classroom.id, :period_id => (@current_classroom_period.nil? ? nil : @current_classroom_period.id), :topic_id => (@current_topic.nil? ? nil : @current_topic.id))
    end


    ###############

    ###############

  private

    def entity_subject_dashboards(entity)
      @entity_dashboards = {}
      ActSubject.all_subjects.each do |subject|
        @entity_dashboards[subject] = entity.ifa_dashboards.for_subject(subject).by_date
      end
    end

    def format_dashboard(dashboard, subject, standard)
      dashboard_cell_hashes(dashboard, subject, standard)
      dashboard_header_info(dashboard, subject, standard)
     # dashboardable_submissions(dashboard, subject )
    end


  def classroom_periods_students
    @classroom_students = {}
    @current_classroom.classroom_periods.each do |per|
      @classroom_students[per] = per.students
    end
  end

  def classroom_submissions
    @pending_teacher_submissions = @current_classroom.act_submissions.pending(:teacher=>@current_user)
    @pending_classroom_submissions = @current_classroom.act_submissions.pending
  end

  def classroom_dashboards

  end

  def get_current_student
    if params[:student_id]
      @current_student = User.find_by_id(params[:student_id]) rescue nil
    end
  end

  def get_current_dashboard
    if params[:ifa_dashboard_id]
      @current_dashboard = IfaDashboard.find_by_id(params[:ifa_dashboard_id]) rescue nil
    end
  end

  def get_current_assessment
    if params[:act_assessment_id]
      @current_assessment = ActAssessment.find_by_id(params[:act_assessment_id]) rescue nil
    end
  end

  def get_current_submission
    if params[:act_submission_id]
      @current_submission = ActSubmission.find_by_id(params[:act_submission_id]) rescue nil
    end
  end

  def get_current_teacher
    if params[:teacher_id]
      @current_teacher = User.find_by_id(params[:teacher_id]) rescue nil
    elsif @current_classroom_period && @current_classroom_period.teachers.size == 1
      @current_teacher = @current_classroom_period.teachers.first
    else
      @current_teacher = nil
    end
  end

  def assessment_pool_info
    @classroom_assessment_list = @current_classroom.available_assessments rescue []
    @teacher_list = @current_classroom_period.teachers
  end

  def current_student_plan
    @current_student_plan = @current_user.ifa_plan_for(@current_subject)
  end


  def create_current_submission?
    @current_submission = ActSubmission.new
    @current_submission.organization_id = @current_organization.id
    @current_submission.user_id = @current_user.id
    @current_submission.classroom_id = @current_classroom.nil? ? nil: @current_classroom.id
    @current_submission.teacher_id = @current_teacher.nil? ? nil: @current_teacher.id
    @current_submission.act_assessment_id = @current_assessment.nil? ? nil: @current_assessment.id
    @current_submission.act_subject_id = @current_assessment.nil? ? nil: @current_assessment.act_subject_id
    @current_submission.act_master_id = @current_provider.master_standard.id
    @current_submission.duration = assessment_duration
    @current_submission.student_comment = params[:act_submission][:student_comment]
    @current_submission.teacher_comment = ''
    if @current_submission.save
      submitted = true
    else
      flash[:error] = @current_submission.errors.full_messages.to_sentence
      submitted = false
    end
    submitted
  end


  def get_entity
    if params[:entity_class] == 'User'
      @entity = User.find_by_public_id(params[:entity_id]) rescue nil
    elsif params[:entity_class] == 'Classroom'
      @entity = Classroom.find_by_public_id(params[:entity_id]) rescue nil
    elsif params[:entity_class] == 'Organization'
      @entity = Organization.find_by_public_id(params[:entity_id]) rescue nil
    else
      @entity = nil
    end
  end

  def sa_answers_completed?
    sa_complete = true
    if params[:short_ans]
      params[:short_ans][:quest_id].each_with_index do |id, idx|
        question = ActQuestion.find_by_id(id) rescue nil
        if !question.nil?
          answer = ActAnswer.new
          answer.act_assessment_id = @current_submission.act_assessment_id
          answer.user_id = @current_submission.user_id
          answer.organization_id = @current_submission.organization_id
          answer.classroom_id = @current_submission.classroom_id
          answer.teacher_id = @current_submission.teacher_id
          answer.act_question_id = id
          answer.was_selected = true
          answer.is_correct = true
          answer.is_calibrated = question.is_calibrated
          answer.act_choice_id = 0
          answer.points = 0.0
          answer.short_answer = params[:short_ans][:answer][idx]
          unless @current_submission.act_answers << answer
            sa_complete = false
          end
        end
      end
    end
    sa_complete
  end
  def sa_answers_review
    params[:question_id].each do |question_id|
      question = ActQuestion.find_by_id(question_id) rescue nil
      answer = @current_submission.short_answer_for_question(question)
      if !question.nil? && !answer.nil? && !params[:short_ans][question_id].nil?
       if params[:short_ans][question_id] != ''
         answer.update_attributes(:points=>(params[:short_ans][question_id].to_f/100.0))
       end
      end
    end
  end

  def mc_answers_completed?
    mc_complete = true
    @current_submission.update_attributes(:tot_choices => (params[:ans_check].nil? ? 0 : params[:ans_check].size),
                                          :tot_points => (params[:ans_check].nil? ? 0.0 : params[:ans_check].map{|aid| ActChoice.find_by_id(aid)}.select{|a| a.correct?}.size.to_f))
    # Selected Choices
    selected_choices = []
    if params[:ans_check]
        params[:ans_check].each_with_index do |choice_id, idx|
          choice = ActChoice.find_by_id(choice_id) rescue nil
          if !choice.nil?
            selected_choices << choice
            answer = ActAnswer.new
            answer.act_assessment_id = @current_submission.act_assessment_id
            answer.user_id = @current_submission.user_id
            answer.organization_id = @current_submission.organization_id
            answer.classroom_id = @current_submission.classroom_id
            answer.teacher_id = @current_submission.teacher_id
            answer.act_question_id = choice.act_question_id
            answer.was_selected = true
            answer.is_correct = choice.correct?
            answer.is_calibrated = choice.act_question.is_calibrated
            answer.act_choice_id = choice_id
            answer.points = choice.correct? ? 1.0 : 0.0
            unless @current_submission.act_answers << answer
              mc_complete = false
            end
          end
        end
    end
    # Unselected Correct Choices
    @current_assessment.correct_test_choices.each do |choice|
      if !selected_choices.include?(choice)
        answer = ActAnswer.new
        answer.act_assessment_id = @current_submission.act_assessment_id
        answer.user_id = @current_submission.user_id
        answer.organization_id = @current_submission.organization_id
        answer.classroom_id = @current_submission.classroom_id
        answer.teacher_id = @current_submission.teacher_id
        answer.act_question_id = choice.act_question_id
        answer.was_selected = false
        answer.is_correct = true
        answer.is_calibrated = choice.act_question.is_calibrated
        answer.act_choice_id = choice.id
        answer.points = 0.0
        unless @current_submission.act_answers << answer
          mc_complete = false
        end
      end
    end
    mc_complete
  end

  def score_submission
    @current_submission.score_it!(@current_provider.master_standard)
  end

  def auto_finalize?
    params[:short_ans].nil? && @current_classroom.ifa_classroom_option.is_ifa_auto_finalize
  end

  def auto_notify?
    @current_classroom.ifa_classroom_option.is_ifa_notify
  end

  def assessment_duration
    if params[:begin_time]
      duration = (Time.now - DateTime.parse(params[:begin_time])).to_i
    else
      duration = 0
    end
    duration
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
