class Apps::AssessmentController < Apps::ApplicationController

  layout "ifa", :except =>[:manual_ifa_dashboard_update, :student_list, :student_baseline_scores, :static_assess_question_analysis, :question_analysis_test,
                           :list_user_questions, :list_subject_assessments, :subject_benchmarks, :subject_standard_benchmarks,
                           :assign_classroom_assessment, :question_analysis, :entity_dashboard, :growth_dashboards, :student_dashboard,
                           :student_subject_history, :classroom_dashboard,  :assign_classroom_assessment_view, :list_classroom_assessments,
                           :subject_readings, :genre_readings, :list_standard_questions ,:subject_questions, :assign_assessment_question_view,
                           :subject_assessments, :list_user_assessments]

  before_filter :set_ifa, :except=>[]
  before_filter :ifa_allowed?, :except=>[]
# before_filter :current_user_app_authorized?, :except=>[:topic_standards_benchmarks]
  before_filter :current_user_app_authorized?, :only=>[:index]
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_ifa_options
  before_filter :current_app_superuser, :only=>[:index]
  before_filter :clear_notification, :except => [:take_assessment]
  before_filter :increment_app_views, :only=>[:index]

#
#   MAIN ASSESSMENT MANAGEMENT CONTROLLERS
  def index
    initialize_parameters
    if @current_provider.ifa_org_option
      @ifa_classroom = params[:classroom_id] ? Classroom.find_by_public_id(params[:classroom_id]) : @current_organization.classrooms.active.first
   #   @master = ActMaster.find_standard('ACT')
   #   @co_master = ActMaster.find_standard('CO')
      @readings = ActRelReading.all
      @readings.sort!{|a,b| a.act_genre.name <=> b.act_genre.name}
      @assessments = ActAssessment.active rescue []
      @active_assessments = ActAssessment.active rescue []    # for IFA rewrite to rid @assessments variable
      @active_questions = ActQuestion.active rescue []
      @active_readings = ActRelReading.by_label   # for IFA rewrite to rid @readings variable
      @current_standard = @current_provider.master_standard.nil? ? ActMaster.default : @current_provider.master_standard
      @current_user_questions = @current_user.act_questions
      @assessments.sort!{|a,b| a.act_subject_id <=> b.act_subject_id}
      @threshold = Time.now - @current_provider.ifa_org_option.sms_calc_cycle.days
      prepare_summary_data
      find_dashboard_update_start_dates(@current_organization)
      question_creators_strands
      assessment_creators
    else
      redirect_to organization_view_path(:organization_id => @current_organization)
    end
  end

  def create
  end

  def manage

    initialize_parameters
    CoopApp.ifa.increment_views
    if @current_provider.ifa_org_option
      @ifa_classroom = params[:classroom_id] ? Classroom.find_by_public_id(params[:classroom_id]) : @current_organization.classrooms.active.first
  #    @master = ActMaster.find(:first, :condition=>["abbrev = ?", "ACT"]) rescue ActMaster.first
      @master = ActMaster.act
  #    @co_master = ActMaster.find(:first, :conditions =>["abbrev = ?", "CO"])rescue ActMaster.first
      @co_master = ActMaster.co
      @readings = ActRelReading.all
      @readings.sort!{|a,b| a.act_genre.name <=> b.act_genre.name}
      @assessments = ActAssessment.active rescue []
      @assessments.sort!{|a,b| a.act_subject_id <=> b.act_subject_id}
      @threshold = Time.now - @current_provider.ifa_org_option.sms_calc_cycle.days

      prepare_summary_dashboard
      find_dashboard_update_start_dates(@current_organization)
    else
       redirect_to organization_view_path(:organization_id => @current_organization)
    end
  end

  def student_list
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @letter_group = params[:letter] rescue nil
  end

  def update_student_demographics

  initialize_parameters
    if params[:user_id]
      @student = User.find_by_public_id(params[:user_id])rescue nil
    end
    unless @student
       redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
    end
  end

  def edit_options

   if @current_provider.ifa_org_option
      school_start_valid = true
      school_start = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d") rescue school_start_valid = false
      @current_provider.ifa_org_option.begin_school_year = school_start if school_start_valid
      #
      # Temp Fix for set school start
      #
      @current_provider.ifa_org_option.begin_school_year = "2015-08-30"

      @current_provider.ifa_org_option.days_til_repeat = params[:option][:days_til_repeat].to_i < 0 ? 0: params[:option][:days_til_repeat].to_i
      if @current_provider.ifa_org_option.update_attributes(params[:ifa_org_option])
        flash[:notice] = "Options Updated Successfully"       
      else
         flash[:error] = @current_provider.ifa_org_option.errors.full_messages.to_sentence
      end
    end
       redirect_to self.send(@current_application.link_path, {:organization_id => @current_organization, :classroom_id => @classroom})
  end


#
#   STATIC PAGE CONTROLLERS
#

  def static_question

    initialize_parameters

    unless  @question
      redirect_to self.send(@current_application.link_path, {:organization_id => @current_organization})
    end
    @rel_reading = @question.act_rel_reading ? @question.act_rel_reading : nil
    @benchmark_list = @question.act_benches.sort_by{|b| [b.benchmark_type, b.description]} rescue []
 #   @classroom_list = Classroom.find(:all, :conditions => ["act_subject_id = ? ",@question.act_subject_id]) rescue []
    @classroom_list = @question.act_subject.nil? ? [] : @question.act_subject.classrooms
    @assess_count = @question.act_assessments.count
    @answered_count = @question.ifa_question_logs.collect{|p| p.choices}.sum 
    @points = @question.ifa_question_logs.collect{|p| p.earned_points}.sum 
    if @answered_count == 0
      @pct_correct = 0
    else
      @pct_correct = 100*@points/@answered_count
    end
 #   @topic_list = Topic.find(:all, :conditions => ["act_score_range_id = ? ", @question.score_range(@current_standard)]) rescue []
    @topic_list = @question.score_range(@current_standard) ? @question.score_range(@current_standard).topics : []
    @rel_topics = []
    if @topic_list
      @topic_list.each do |tpc|
       if @classroom_list.include?(tpc.classroom) && tpc.act_standards.include?(@question.standard(@current_standard))
         @rel_topics << tpc
       end
      end
    end
    @originator = "Unkown Creator"
    if @question.generation > 0
      original = ActQuestion.find(@question.original_question_id) rescue nil
      unless original.nil?
       @originator = original.organization.short_name + ", " + original.user.last_name
      end
    end
    @standards_authority = true
  end

  def static_assessment
    initialize_parameters 
    unless @assessment 
      redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question})
    end
    @originator = "Unkown Creator"
    if @assessment.generation > 0
      original = ActAssessment.find(@assessment.original_assessment_id) rescue nil
      unless original.nil?
       @originator = original.organization.short_name + ", " + original.user.last_name
      end
    end
    if @assessment.user_id == @current_user.id
      @allow_resequence = true
    end
  end

  def static_benchmark

    initialize_parameters

    unless  @benchmark
      redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
    end
    @bench_questions = @benchmark.act_questions rescue nil
    @bench_assessments = []
    @bench_answers = []
    @all_students = []
    @all_classrooms = []
    @all_schools = []
    @all_teachers = []
    @all_points = 0
    @all_pct_correct = 0
    @teacher_answers = []
    @teacher_students = []
    @teacher_points = 0
    @teacher_pct_correct = 0    
 #   @highschools = Organization.find(:all, :conditions =>["organization_type_id = ?", 2]).sort{|a,b| a.name <=> b.name} rescue nil
    @highschools = Organization.highschools.sort{|a,b| a.name <=> b.name}
    if @bench_questions
      @bench_answers = @bench_questions.collect{|q| q.act_answers.selected}.flatten
      unless @bench_answers.empty?
        @all_students = @bench_answers.collect{|a| a.user_id}.uniq
        @all_points = @bench_answers.collect{|a| a.points}.sum
        @all_pct_correct = 100*@all_points/@bench_answers.size
        @teacher_answers = @bench_answers.select{|a| a.teacher_id == @current_user.id}
        @all_classrooms = @bench_answers.collect{|a| a.classroom}.uniq        
        @all_schools = @bench_answers.collect{|a| a.organization}.uniq    
        @all_teachers = @bench_answers.collect{|a| a.teacher_id}.uniq
        @teachers = []
        @all_teachers.each do |t|
          @teachers << User.find_by_id(t) rescue nil
        end
        @teachers = @teachers.sort_by{|t| [t.organization.name, t.last_name, t.first_name]}
        @all_classrooms = @all_classrooms.sort_by{|c| [c.organization.name, c.course_name]}
        unless @teacher_answers.empty?
          @teacher_students = @teacher_answers.collect{|a| a.user_id}.uniq
          @teacher_points = @teacher_answers.collect{|a| a.points}.sum
          @teacher_pct_correct = 100*@teacher_points/@teacher_answers.size      
        end
       end     
      @bench_assessments = @bench_questions.collect{|q| q.act_assessments}.flatten    
    end
  end

 
 def toggle_standard
   initialize_parameters 
   @question.update_attributes(:is_calibrated =>!@question.is_calibrated)
   @question.calibrate_assessments
   redirect_to ifa_question_show_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question)
 end

#
#   ASSESSMENTS
#
  def subject_assessments
   
   initialize_parameters 
  
  end

  def list_subject_assessments
    initialize_parameters
  end
  
  def list_user_assessments
    initialize_parameters
  end 


  def add_assessment
   
   initialize_parameters 
    
    if params[:function]=="New"
      @assessment = ActAssessment.new
    else
      if params[:function] == "Submit"
        @assessment = ActAssessment.new
        @assessment.act_subject_id = params[:assess][:subj_id]
        @assessment.name = params[:assess][:name]
        @assessment.comment = params[:assess][:comment]
        @assessment.is_locked = false
        @assessment.is_calibrated = false
        @assessment.user_id = @current_user.id
        @assessment.organization_id = @current_organization.id
        @assessment.generation = 0
      end
      if @assessment.save
        @assessment.original_assessment_id = @assessment.id     
        @assessment.update_attributes params[:act_assessment]
        @master_standards.each do |std|
          range = ActAssessmentScoreRange.new
          range.act_assessment_id = @assessment.id
          range.standard = std.abbrev.downcase
          range.act_master_id = std.id
          range.upper_score = 0
          range.lower_score = 0
          range.save
          end
        redirect_to ifa_assessment_update_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question, :assessment_id => @assessment)
      end 
      flash[:error] = @assessment.errors.full_messages.to_sentence 
    end
  end

  def edit_assessment
   initialize_parameters 

  # @avail_questions = ActQuestion.find(:all, :conditions => ["act_subject_id = ?", @assessment.act_subject_id])
   @avail_questions = @assessment.act_subject ? @assessment.act_subject.act_questions : []
   if params[:function] == "Submit"
      
      if params[:position]
        positions = params[:position].collect{|p| p}

        params[:question_id].each_with_index do |q,i|
        ass_question = ActAssessmentActQuestion.find_by_id(q) rescue nil
          if ass_question && positions[i] then
            ass_question.update_attributes(:position => positions[i])
          end
       end  
      end
      
      add_count = 0
      remove_count = 0
      params[:quest_check] ||= []
      quest_list = []
      params[:quest_check].each do |q|
      question = ActQuestion.find_by_id(q)rescue nil
      unless question.nil?
        quest_list<<question
        end
      end
      quest_list.uniq.each do |question|    
        if @assessment.act_questions.include?(question) 
          then
          @assessment.act_questions.delete question
          remove_count += 1
         else
          @assessment.act_questions<<question
         add_count +=1
        end
      end
 
      if @assessment.update_attributes params[:act_assessment]
          ActAssessmentScoreRange.destroy_all(["act_assessment_id = ? AND act_master_id = ?", @assessment.id, @current_standard.id])rescue nil
          range = ActAssessmentScoreRange.new
          range.upper_score = @assessment.max_question_score(@current_standard)
          range.lower_score = @assessment.min_question_score(@current_standard)
          range.act_assessment_id = @assessment.id
          range.act_master_id = @current_standard.id
          range.standard = @current_standard.abbrev.downcase
          range.save  
          @assessment.calibrate
          @assessment.check_lock
          flash[:notice] = "Assessment Updated Successfully: #{add_count} Questions Added, #{remove_count} Questions Removed"       
        else
         flash[:error] = @assessment.errors.full_messages.to_sentence 
       end
       redirect_to ifa_assessment_view_path(:organization_id => @current_organization, :classroom_id => @classroom, :assessment_id => @assessment)
    end
    if @assessment 
      then 
       @assess_questions = @assessment.act_questions.collect{|q| q}
      else
      @assess_questions  = []
    end
 #   @avail_questions = ActQuestion.find(:all, :conditions => ["act_subject_id = ?", @assessment.act_subject_id])
   @avail_questions = @assessment.act_subject ? @assessment.act_subject.act_questions : []
  end

  def add_ifa_assessment
  
  initialize_parameters
      
     @assessment = ActAssessment.new
     unless params[:assess].nil?
      @assessment.act_subject_id = ActSubject.find_by_id(params[:assess][:subject_id]).id rescue ActSubject.first.id
     else
      @assessment.act_subject_id = ActSubject.first.id
     end
     @assessment.name = "* * New Assessment * *"
     @assessment.is_locked = false
     @assessment.is_calibrated = false
     @assessment.is_active = false
     @assessment.user_id = @current_user.id
     @assessment.organization_id = @current_organization.id
     @assessment.generation = 0
     if @assessment.save
       @assessment.update_attributes(:original_assessment_id => @assessment.id)
       @current_provider.ifa_org_option.act_masters.each do |std|
          range = ActAssessmentScoreRange.new
          range.standard = std.abbrev.downcase
          range.act_master_id = std.id
          range.upper_score = 0
          range.lower_score = 0
          @assessment.act_assessment_score_ranges<<range
          end
     end
     redirect_to ifa_assessment_edit_path(:organization_id => @current_organization, :classroom_id => @classroom, :assessment_id => @assessment)
 end

	def edit_ifa_assessment
   initialize_parameters 

   if params[:function] == "Submit"
      unless @assessment.is_locked
        @assessment.is_active = true
        if @assessment.update_attributes params[:act_assessment]
            flash[:notice] = "Assessment Updated Successfully"       
          else
            flash[:error] = @assessment.errors.full_messages.to_sentence 
        end
      else
        flash[:error] = "Assessment Locked Cannot Be Updated" 
      end
     end
  end

  def assign_assessment_question_view
  
  initialize_parameters
    @score_range = ActScoreRange.find_by_public_id(params[:range])
    @range_questions = @score_range.act_questions - @assessment.act_questions
    @assess_questions = @assessment.act_questions.collect{|q| q}

  end


  def copy_assessment
  
  initialize_parameters
  
    if @assessment
      @new_assessment = ActAssessment.new
      @new_assessment = @assessment.clone
      @new_assessment.is_locked = false
      @new_assessment.created_at = Time.now
      @new_assessment.updated_at = Time.now
      @new_assessment.user_id = @current_user.id
      @new_assessment.organization_id = @current_organization.id
      @new_assessment.generation += 1
       if @new_assessment.save
   #       ranges = ActAssessmentScoreRange.find(:all, :conditions => ["act_assessment_id = ?", @assessment.id])rescue nil
        ranges = @assessment.act_assessment_score_ranges
            ranges.each do |r|
            new_range = ActAssessmentScoreRange.new
            new_range.act_assessment_id = @new_assessment.id
            new_range.standard = r.standard
            new_range.act_master_id = r.act_master_id
            new_range.lower_score = r.lower_score
            new_range.upper_score = r.upper_score
            new_range.save
            end
          flash[:notice] = "Assessment Copied Successfully"  
          assess_questions = @assessment.act_questions.collect{|q| q}
          assess_questions.each do |q| 
          @new_assessment.act_questions<<q
            end
          @assessment = ActAssessment.find_by_id(@new_assessment.id)
        else
         flash[:error] = @new_assessment.errors.full_messages.to_sentence 
       end
     end
   redirect_to ifa_assessment_view_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question, :assessment_id => @assessment)
  end

  def destroy_assessment
  
  initialize_parameters
 
    if @current_user == @assessment.user || @current_user.ifa_admin_for_org?(@current_organization)
      @assessment.destroy
      flash[:notice] = "Assessment Deleted"    
      end
    redirect_to self.send(@current_application.link_path, {:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question})
  end

  def unlock_assessment
  
  initialize_parameters
 
    if @assessment.is_locked
      @assessment.is_locked = false
    else
      @assessment.is_locked = true
    end
    @assessment.update_attributes params[:act_assessment]
    redirect_to ifa_assessment_view_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question, :assessment_id => @assessment)
  end


#
#   CLASSROOM ASSESSMENTS
#

  def assign_classroom_assessment
    initialize_parameters
    if @classroom  then 
      @classroom_assessments = @classroom.act_assessments
      else
      @classroom_assessments = []
    end
    @tagged_classrooms = @current_user.favorite_classrooms.sort_by{|c|[c.act_subject.name, c.course_name]} rescue []
    @tagged_classrooms.select!{|cl| (cl.act_assessments.size > 0) && (cl != @classroom)}
  end

  def assign_classroom_assessment_view
    initialize_parameters
    if params[:group_id]
      @tagged_classroom = Classroom.find_by_public_id(params[:group_id]) rescue nil
    end
  #  get_assessments_from_repository
    @assessment_pool = ActAssessment.active.sort!{|a,b| b.updated_at <=> a.updated_at}
  end 
   
 def assign_assessments_to_classroom
  initialize_parameters
    add_count = 0
    remove_count = 0 
    params[:res_check] ||= []
    ass_list = []
    params[:res_check].each do |r|
    ass = ActAssessment.find_by_id(r)rescue nil
      unless ass.nil?
       ass_list<<ass
      end
    end
    ass_list.uniq.each do |assessment|    
      if @classroom.act_assessments.include?(assessment) 
        then
        @classroom.act_assessments.delete assessment
        remove_count += 1
        else
          @classroom.act_assessments<<assessment
          add_count +=1
        end
     end      
       flash[:notice] = "#{add_count} Assessments Added,  #{remove_count} Assessments Removed" 

    @avail_resources = (@current_user.favorite_resources + @classroom.contents).uniq.compact
    @avail_resources.sort!{|a,b| a.content_resource_type.name.capitalize <=> b.content_resource_type.name.capitalize}
    @authorization_levels = AuthorizationLevel.all(:include => :applicable_scopes, :conditions => ["authorization_levels.name NOT IN ('superuser', 'favorite') AND applicable_scopes.name = ?", "Classroom"])  
    
     redirect_to :controller => 'site/site', :action => 'assign_classroom_general', :organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic
 end  

  def take_assessment
    initialize_parameters
    @ifa_classroom = @classroom
    @current_subject = @classroom.act_subject
    @last_submission = @current_user.act_submissions.for_subject(@current_subject).empty? ? nil : @current_user.act_submissions.for_subject(@current_subject).last
    @current_student_plan = @current_user.ifa_plan_for(@current_subject)
    @suggested_topics = @current_student_plan.nil? ? [] : @current_student_plan.classroom_lus(@classroom)

    @assessment_subjects = @current_user.act_submissions.collect{|s| s.act_subject}.uniq rescue []
    @dashboard_subjects = @current_user.ifa_dashboards.collect{|s| s.act_subject}.compact.uniq rescue []
    start_date = @current_provider.ifa_org_option.begin_school_year
     prepare_ifa_dashboard(@current_user, start_date, Date.today)    
#    @current_student_dashboards = @current_user.ifa_dashboards.for_subject_since(@classroom.act_subject,(@current_provider.ifa_org_option.begin_school_year - 1.years)).reverse
    @classroom_assessment_list = @classroom.act_assessments.active.lock rescue []

  #  @suggested_topics = @classroom.topics.select{|t| t.act_score_ranges.for_standard(@current_standard).first.upper_score >= @current_sms && t.act_score_ranges.for_standard(@current_standard).first.lower_score <= @current_sms}rescue nil
 
    if params[:function] == "Success"
      @success = true
    end
    @success = true
    student_assessment_dashboard(@last_submission)
    assessment_header_info(@last_submission, ActMaster.default_std)
    user_ifa_plans
    find_dashboard_update_start_dates(@current_user)
  end

  def submit_assessment
    initialize_parameters    
    if @assessment 
      then 
       @assess_questions = @assessment.act_questions.collect{|q| q}
      else
      @assess_questions  = []
    end
 #   @avail_questions = ActQuestion.find(:all, :conditions => ["act_subject_id = ?", @assessment.act_subject_id])
    @avail_questions = @assessment.act_subject.nil? ? [] : ActQuestion.for_subject(@assessment.act_subject)
    if params[:function]=="Assess"
      @teacher_list = @classroom.teachers_for_student(@current_user).sort{|a,b| a.last_name.downcase <=> b.last_name.downcase}
      if @teacher_list.size == 1
        @teacher = @teacher_list.first
      end
      @classroom_name = @classroom.course_name.upcase 
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

   def add_submission

     initialize_parameters

     @submission = ActSubmission.new
     @submission.user_id = @current_user.id
     @submission.act_assessment_id = @assessment.id
     @submission.classroom_id = @classroom.id
     @submission.organization_id = @current_organization.id
     @submission.is_final = false
     @submission.act_subject_id = @assessment.act_subject_id
     if params[:begin_time]
       @submission.duration = (Time.now - DateTime.parse(params[:begin_time])).to_i
     else
       @submission.duration = 0
     end
     if params[:teacher]
       @submission.teacher_id = params[:teacher][:teacher_id]
     end
     if params[:act_submission]
       @submission.student_comment = params[:act_submission][:student_comment]
     end
     submission_complete = false
     if @submission.save
       teacher_must_review = false
       chosen_ids = []
       unless params[:ans_check].nil?
         chosen_ids = params[:ans_check].collect{|c| c}
       end
       sa_ids = []
       sa_answers = []
       unless params[:short_ans].nil?
         sa_ids = params[:short_ans][:quest_id].collect{|i| i}
       end
       @assessment.act_questions.each do |q|
         if q.question_type == "SA"
         then
           teacher_must_review = true
           @answer = @submission.act_answers.new
           @answer.act_assessment_id = @assessment.id
           @answer.user_id = @current_user.id
           @answer.organization_id = @current_organization.id
           @answer.classroom_id = @classroom.id
           @answer.teacher_id = @submission.teacher_id
           @answer.act_question_id = q.id
           @answer.was_selected = true
           @answer.is_correct = true
           @answer.is_calibrated = q.is_calibrated
           @answer.act_choice_id = 0
           @answer.points = 0.0
           @answer.short_answer = []
           sa_ids.each_with_index do |saq,idx|
             if saq == q.id.to_s
               @answer.short_answer = params[:short_ans][:answer][idx]
             end
           end
           if @answer.save
             submission_complete = true
           end
         else
           correct_choice_ids = q.act_choices.select{|c| c.is_correct == true}.collect{|chc| chc.id}
           incorrect_choice_ids = q.act_choices.select{|c| c.is_correct == false}.collect{|chc| chc.id}

           correct_choice_ids.each do |cc|
             if chosen_ids.include?(cc.to_s)
  #   Correct Answer Selected
               @answer = @submission.act_answers.new
               @answer.act_assessment_id = @assessment.id
               @answer.user_id = @current_user.id
               @answer.organization_id = @current_organization.id
               @answer.classroom_id = @classroom.id
               @answer.teacher_id = @submission.teacher_id
               @answer.act_question_id = q.id
               @answer.act_choice_id = cc
               @answer.was_selected = true
               @answer.is_correct = true
               @answer.is_calibrated = q.is_calibrated
               @answer.points = 1.0
               if @answer.save
                 submission_complete = true
               end
             else
  #   Correct Answer Not Selected
               @answer = @submission.act_answers.new
               @answer.act_assessment_id = @assessment.id
               @answer.user_id = @current_user.id
               @answer.organization_id = @current_organization.id
               @answer.classroom_id = @classroom.id
               @answer.teacher_id = @submission.teacher_id
               @answer.act_question_id = q.id
               @answer.act_choice_id = cc
               @answer.was_selected = false
               @answer.is_correct = true
               @answer.is_calibrated = q.is_calibrated
               @answer.points = 0.0
               if @answer.save
                 submission_complete = true
               end
             end
           end
           incorrect_choice_ids.each do |nc|
             if chosen_ids.include?(nc.to_s)
  #   InCorrect Answer Selected
               @answer = @submission.act_answers.new
               @answer.act_assessment_id = @assessment.id
               @answer.user_id = @current_user.id
               @answer.organization_id = @current_organization.id
               @answer.classroom_id = @classroom.id
               @answer.teacher_id = @submission.teacher_id
               @answer.act_question_id = q.id
               @answer.act_choice_id = nc
               @answer.was_selected = true
               @answer.is_correct = false
               @answer.is_calibrated = q.is_calibrated
               @answer.points = 0.0
               if @answer.save
                 submission_complete = true
               end
             end
           end
         end
       end    # end of Question loop
     end
     if submission_complete && !@submission.organization.nil?
       @submission.update_attributes params[:tot_points => @submission.total_points, :tot_choices => @submission.total_choices]
       @submitted_answers = @submission.act_answers
       ActSubmissionScore.destroy_all(["act_submission_id = ?", @submission.id])rescue nil
       #  ActMaster.find(:all).each do |mstr|
       @submission.organization.ifa_standards.each do |mstr|
         std_score = ActSubmissionScore.new
         std_score.act_submission_id = @submission.id
         std_score.act_master_id = mstr.id
         #  std_score.est_sms = mstr.sms(@submitted_answers,@submission.act_subject_id,0,0, @current_organization.id)
         std_score.est_sms = @submission.standard_assessment_score(mstr)
       #  std_score.update_attributes params[:act_submission_score]
         std_score.save
       end
       unless teacher_must_review || !@classroom.ifa_classroom_option.is_ifa_auto_finalize
         @submission.finalize(true, @submission.teacher_id)
         # finalize_submission(@submission)
       else
         teacher_must_review = true
       end
       if @classroom.ifa_classroom_option.is_ifa_notify
         teacher = User.find(@submission.teacher_id)
         UserMailer.assessment_submission(teacher, @current_user,@classroom, @current_organization, teacher_must_review, request.host_with_port).deliver
       end
       flash[:notice] = "Assessment Submitted To " + @submission.teacher.last_name
       redirect_to ifa_assessment_take_path(:organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic, :assessment_id => @assessment,:submission_id => @submission, :function => "Success")
     else
       flash[:error] = @submission.errors.full_messages.to_sentence
       redirect_to ifa_assessment_submit_path(:organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic, :assessment_id => @assessment)
     end
   end

  def teacher_review
  initialize_parameters
    @ifa_classroom = @classroom
    @current_subject = @classroom.act_subject
  #   prepare_ifa_dashboard(@classroom, (Date.today - 2.months), Date.today)
    @all_submitted_assessments = @classroom.act_submissions.for_teacher(@current_user)
    @assessment_subjects = @all_submitted_assessments.collect{|s| s.act_subject}.uniq rescue []
    @pending_assessments = @all_submitted_assessments.select{|s|!s.is_final}.sort{ |a,b| b.created_at <=> a.created_at }
    @student_list = @classroom.participants.sort{|a,b| a.last_name <=> b.last_name}
  #  @current_classroom_dashboards = @classroom.ifa_dashboards.since(@options.begin_school_year.end_of_month).sort_by{|a| a.act_subject.name}.sort{|a,b| b.period_end <=> a.period_end}
    @current_classroom_dashboards = @classroom.ifa_dashboards.for_subject(@current_subject).select{|d| !d.period_end.nil? && !d.organization_id.nil?}
  #  @current_classroom_dashboards = @classroom.ifa_dashboards.select{|d| !d.act_subject.nil? && !d.period_end.nil? && !d.organization_id.nil?}
  #  find_dashboard_update_start_dates(@classroom)
    aggregate_dashboard_cell_hashes(@current_classroom_dashboards, @current_subject, @current_user.standard_view)
    aggregate_dashboard_header_info(@current_classroom_dashboards, @current_subject, @current_user.standard_view, @classroom)

  end

  def range_change_dashboard
    get_entity
    get_standard
    get_subject
    start_date = Date.new(params[:start_yr].to_i, params[:start_mth].to_i, 1)
    end_date = Date.new(params[:end_yr].to_i, params[:end_mth].to_i, 1).end_of_month
    @dashboards = @entity.ifa_dashboards.subject_between_periods(@current_subject, start_date, end_date)
    aggregate_dashboard_cell_hashes(@dashboards, @current_subject, @current_standard)
    aggregate_dashboard_header_info(@dashboards, @current_subject, @current_standard, @entity)

    render :partial => "ifa/ifa_dashboard/dashboard",
           :locals=>{:dashboard => @entity, :subject => @current_subject, :standard=>@current_standard, :cell_corrects=>@cell_correct,
                     :cell_totals=>@cell_total, :cell_pcts=>@cell_pct, :cell_color=>@cell_color, :cell_font=>@cell_font,
                     :cell_milestones=>@cell_milestone, :cell_achieves=>@cell_achieve}
  end

  def destroy_pending_all
    initialize_parameters
    @classroom.act_submissions.for_teacher(@current_user).not_final.destroy_all
    @all_submitted_assessments = @classroom.act_submissions.for_teacher(@current_user)
    @pending_assessments = @all_submitted_assessments.select{|s|!s.is_final}.sort{ |a,b| b.created_at <=> a.created_at }
    render :partial => "/apps/assessment/teacher_review_pending"
  end


  def destroy_pending
    initialize_parameters
    if @submission
      @submission.destroy_it
    end
    @all_submitted_assessments = @classroom.act_submissions.for_teacher(@current_user)
    @pending_assessments = @all_submitted_assessments.select{|s|!s.is_final}.sort{ |a,b| b.created_at <=> a.created_at }
    render :partial => "/apps/assessment/teacher_review_pending"
  end

  def org_analysis
    initialize_parameters
    get_subject
    start_date = @current_provider.ifa_org_option.begin_school_year.beginning_of_month
    end_date = Date.today.end_of_month
    @organization_dashboards = @current_organization.ifa_dashboards.subject_between_periods(@current_subject, start_date, end_date) rescue []
    aggregate_dashboard_cell_hashes(@organization_dashboards, @current_subject, @current_standard)
    aggregate_dashboard_header_info(@organization_dashboards, @current_subject, @current_standard, @current_organization)
    org_analysys_instance_variables
    student_growth_plans
  end

  def growth_dashboards
    initialize_parameters
    @show_details = params[:details] rescue nil
    @entity_dashboards = []
    @group = params[:group]
    if @group == "organization"
      @entity =  Organization.find_by_public_id(params[:id])
      @entity_dashboards =  @entity.ifa_dashboards.for_subject_since(@current_subject, (@options.begin_school_year - 1.years)).reverse rescue []
    end
    if @group == "classroom"
      @entity =  Classroom.find_by_public_id(params[:id])
      @entity_dashboards =  @entity.ifa_dashboards.for_subject_since(@current_subject, @options.begin_school_year).reverse rescue []
    end
    if @group == "student"
      @entity =  User.find_by_public_id(params[:id])
      @entity_dashboards =  @entity.ifa_dashboards.for_subject_since(@current_subject, @options.begin_school_year).reverse rescue []
    end
  end

  def entity_dashboard
    initialize_parameters
    @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
    unless @entity_dashboard
      period = params[:period].to_date rescue Date.today
      entity_id = params[:entity_id] rescue ""
      entity_class = params[:entity_class].to_s rescue ""
     # @entity_dashboard_xx = IfaDashboard.find(:first, :conditions =>["ifa_dashboardable_type = ? && ifa_dashboardable_id = ? && period_end = ?", entity_class, entity_id, period ])
      @entity_dashboard = IfaDashboard.for_entity(entity_class, entity_id, period)
    end
    prepare_single_ifa_dashboard(@entity_dashboard)
    @show_details = params[:details] rescue nil
    prepare_single_dashboard_details
  end

  def refresh_dashboard_scores
  
  initialize_parameters
  
    @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
    unless @entity_dashboard
      redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization})
    end
    update_sms_in_user_dashboard(@entity_dashboard) 
    prepare_single_ifa_dashboard(@entity_dashboard)
    @show_details = params[:details] rescue nil
    prepare_single_dashboard_details
   
    render :partial => "/apps/assessment/ifa_dashboard", :locals => {:div_key => (@entity_dashboard ? @entity_dashboard.public_id : "entity"), :dashboard => (@entity_dashboard ? @entity_dashboard : nil)}
  end

   def dashboard_submissions

     initialize_parameters

     @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
     if @entity_dashboard.nil?
       redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization})
     end
     ActSubmission.not_dashboarded(@entity_dashboard.ifa_dashboardable_type, @entity_dashboard.ifa_dashboardable, @current_subject, @entity_dashboard.period_beginning, @entity_dashboard.period_ending).each do |submission|
       if @entity_dashboard.ifa_dashboardable_type == 'User'
         submission.dashboard_it(submission.user)
         # auto_ifa_dashboard_update(@submission, @submission.user)
       elsif @entity_dashboard.ifa_dashboardable_type == 'Classroom'
         submission.dashboard_it(submission.classroom)
         # auto_ifa_dashboard_update(@submission, @submission.classroom)
       elsif @entity_dashboard.ifa_dashboardable_type == 'Organization'
         submission.dashboard_it(submission.organization)
         # auto_ifa_dashboard_update(@submission, @submission.organization)
       end
     end
     @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
     prepare_single_ifa_dashboard(@entity_dashboard)
     @show_details = params[:details] rescue nil
     prepare_single_dashboard_details
     render :partial => "/apps/assessment/ifa_dashboard", :locals => {:div_key => (@entity_dashboard ? @entity_dashboard.public_id : "entity"), :dashboard => (@entity_dashboard ? @entity_dashboard : nil)}
   end

   def tbdashboard_submissions
     initialize_parameters
     entity_class = params[:entity_class]
     period_end = DateTime.parse(params[:period])
     period_begin = period_end.beginning_of_month
     if entity_class == 'Organization'
       entity = Organization.find_by_public_id(params[:entity_id]) rescue nil
        entity_name = entity.name
     elsif entity_class == 'Classroom'
       entity = Classroom.find_by_public_id(params[:entity_id]) rescue nil
       entity_name = entity.name
     else
       entity = nil
     end
     unless entity.nil?
       ActSubmission.not_dashboarded(entity_class, entity, @current_subject, period_begin, period_end).each do |submission|
         if entity_class == 'User'
           submission.dashboard_it(submission.user)
         elsif entity_class == 'Classroom'
           submission.dashboard_it(submission.classroom)
         elsif entity_class == 'Organization'
           submission.dashboard_it(submission.organization)
         end
       end
     end
     org_analysys_instance_variables
     render :partial => "/apps/assessment/org_analysis_tabs"
   end

  def refresh_dashboard_cells
  
  initialize_parameters
  
    @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
    unless @entity_dashboard
      redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization})
    end
    update_cells_in_user_dashboard(@entity_dashboard) 
    prepare_single_ifa_dashboard(@entity_dashboard)
    @show_details = params[:details] rescue nil
    prepare_single_dashboard_details
   
    render :partial => "/apps/assessment/ifa_dashboard", :locals => {:div_key => (@entity_dashboard ? @entity_dashboard.public_id : "entity"), :dashboard => (@entity_dashboard ? @entity_dashboard : nil)}
  end

  def switch_standard_view
  
  initialize_parameters
  
    @entity_dashboard = IfaDashboard.find_by_public_id(params[:dashboard_id])rescue nil
    @current_standard = ActMaster.find_by_id(params[:master_id]) rescue @current_standard 
    unless @entity_dashboard
      redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization})
    end
    @current_user.set_standard_view(@current_standard)
    prepare_single_ifa_dashboard(@entity_dashboard)
    @show_details = params[:details] rescue nil
    prepare_single_dashboard_details
   
    render :partial => "/apps/assessment/ifa_dashboard", :locals => {:div_key => (@entity_dashboard ? @entity_dashboard.public_id : "entity"), :dashboard => (@entity_dashboard ? @entity_dashboard : nil)}
  end

  def student_dashboard_x
  
  initialize_parameters
  
    @student = User.find_by_public_id(params[:id])rescue nil

    @student_all_submissions = @student.act_submissions.final.sort{|a,b| b.id <=> a.id}
    @student_classroom_submissions = @student_all_submissions.select{|s| s.classroom_id == @classroom.id }.sort{|a,b| b.date_finalized<=> a.date_finalized}
    
  #  @standards_list = ActStandard.find(:all, :conditions => ["act_subject_id =? && act_master_id = ?", @classroom.act_subject_id, @current_standard.id], :order => "abbrev")
    @standards_list = ActStandard.for_standard_and_subject(@current_standard, @classroom.act_subject)
 # @range_list = ActScoreRange.find(:all, :conditions => ["act_subject_id = ? && upper_score > ? && act_master_id = ?", @classroom.act_subject_id, 0, @current_standard.id], :order => "upper_score")
    @range_list = ActScoreRange.standard_subject_greater_than_upper(@current_standard, @classroom.act_subject, 0)
    @current_subject = @classroom.act_subject
    @answer_list = @classroom.act_answers.selected.select{|a| a.teacher_id == @current_user.id && a.user_id == @student.id }

    @num_assessments = @student_classroom_submissions.size
    @num_qa = @answer_list.size
    @sms_score = @current_standard.sms(@answer_list, @classroom.act_subject_id, 0,0, @current_organization.id)
    @stats_group = "submission"
    @stats = @current_standard.sms_stats(@answer_list, @classroom.act_subject_id, 0,0, @current_organization.id, @stats_group)
    unless @stats[0] == 1
      group_string = @stats_group + "s"
    else
      group_string = @stats_group
    end
    @header2_string = @classroom.course_name.upcase + ", " + @student.full_name 
    @header3_string = @stats[0].to_s + "&nbsp;Assessments Taken" + ",&nbsp;&nbsp;" + @num_qa.to_s + " Answer Choices" + ",&nbsp;&nbsp;Current Mastery Level: " + @sms_level.to_s
    @header4_string = @current_standard.abbrev + "Mastery Variability Among " + group_string.titleize + ": " + @stats[4].to_s 
    @header5_string = ""
# get recent submissions
    @begin_date = Time.now - @options.sms_calc_cycle.days
    @recent_answers =  @answer_list.select{|a| a.created_at > @begin_date}   
    @sms_level = @current_standard.sms(@recent_answers, @classroom.act_subject_id, 0,0, @current_organization.id)
    @hover = "student"
  end

  def final_assessment_review
    initialize_parameters    
    @finalized = false
    if @submission 
      then 
       @assessment = @submission.act_assessment
       @submission_questions = @assessment.act_questions
       @submission_answers = @submission.act_answers
       @student = User.find_by_id(@submission.user_id)rescue nil
       @teacher = User.find_by_id(@submission.teacher_id)rescue nil
       @reviewer = User.find_by_id(@submission.reviewer_id)rescue nil
 #      @sms_score = @current_standard.sms(@submission_answers,@submission.act_subject_id,0,0, @current_organization.id)
    end
    if params[:function] == "Submit"
      @reviewer = @current_user
      sa_credits_ok = true  
          # SA Questions?
      if params[:credit]
        params[:credit].each do |question_id,value|
          answer = @submission.act_answers.select{|a| a.act_question_id == question_id.to_i}.first
          credit = value.to_f/4.0
          unless answer.update_attributes(:points => credit)
            sa_credits_ok = false
          end
        end  # end of SA Answer loop
      end  # end of Check for SA credit
      if sa_credits_ok
          @submission.finalize(false, @reviewer.id)
          #finalize_submission(@submission)
      end
      unless @finalized
        flash[:error] = @submission.errors.full_messages.to_sentence
      end
    redirect_to ifa_teacher_review_path(:organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic)
    else
    render :layout => "act_assessment"
    end
  end

  def final_assessment_view
    initialize_parameters    
    if @submission 
      then 
       @assessment = @submission.act_assessment
       @submission_questions = @assessment.act_questions
       @submission_answers = @submission.act_answers
       @teacher = User.find_by_id(@submission.teacher_id) rescue nil
       @reviewer = User.find_by_id(@submission.reviewer_id) rescue nil
      else
       redirect_to ifa_teacher_review_path(:organization_id => @current_organization, :classroom_id => @classroom, :topic_id => @topic)
    end
    render :layout => "act_assessment"
  end

  def view_submission
    initialize_parameters    
    if @submission 
      then 
       @assessment = @submission.act_assessment
       @submission_questions = @assessment.act_questions
       @submission_answers = @submission.act_answers
       @teacher = User.find_by_id(@submission.teacher_id) rescue nil
       @reviewer = User.find_by_id(@submission.reviewer_id) rescue nil
      else
       redirect_to ifa_teacher_review_path(:organization_id => @current_organization, :classroom_id => @classroom)
    end
    render :layout => "act_assessment"
  end



  def topic_standards_benchmarks
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    @classroom =Classroom.find_by_public_id(params[:classroom_id])  rescue nil
    @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    render :layout => false
  end
#
# Repository Analysis
#
  def repository_analysis
  
  initialize_parameters
  
    @subjects = ActSubject.all_subjects
    @repository_size = ActQuestion.all.size
    @time_window = (Time.now - @options.months_for_questions.months).beginning_of_month
    @answer_count = ActAnswer.selected_and_after(@time_window).size
  end
  
 def question_analysis
  
    initialize_parameters
    @mastery = ActScoreRange.find_by_public_id(params[:range])
    @question_ranges = ActQuestionActScoreRange.for_mastery_level(@mastery)rescue nil
    @questions = @question_ranges.collect{|q| q.act_question}.flatten
    @answers = @questions.collect{|q| q.act_answers.selected}.flatten
    @time_window = (Time.now - @options.months_for_questions.months).beginning_of_month
  end
  
#
#   BENCHMARKS
#
  def subject_benchmarks
  
  initialize_parameters
    @master = ActMaster.find_by_public_id(params[:master]) rescue ActMaster.first   
  end

  def subject_standard_benchmarks
  
  initialize_parameters
    @master = ActMaster.find_by_public_id(params[:master]) rescue ActMaster.first
    @strand = ActStandard.find_by_id(params[:std_id]) rescue nil
    @std_benchmarks = @master.act_benches.for_strand(@strand).sort_by{|a| [a.act_score_range.upper_score]} rescue []
    if @current_user.ifa_admin_for_org?(@current_organization)
      @edit_authorized = true
    end
  end

  def add_benchmark
    initialize_parameters
    
    if params[:function]=="New"
      @benchmark = ActBench.new
      @standard = ActStandard.find_by_id(params[:std_id])
      if params[:gle_id]
        @gle = CoGle.find_by_id(params[:gle_id])
      end
      @benchmark.standard = @standard.standard
      @benchmark.act_master = @standard.act_master
      @benchmark.act_subject_id = @standard.act_subject.id
      @benchmark.act_standard_id = @standard.id
      
      @benchmark.description = ""
    else

     if params[:function] == "Submit"
       b_score_ids = []
       b_type_ids = []
       b_descripts = []
       params[:score].each do |idx,score_id|
          b_score_ids << score_id
        end
        params[:type].each do |idx,type_id|
          b_type_ids << type_id
        end
        params[:descript].each do |idx,descr|
          b_descripts << descr
        end
      [0,1,2,3,4,5,6,7,8,9].each do |bnch| 
       unless b_score_ids[bnch].empty? || b_type_ids[bnch].empty? || b_descripts[bnch].empty?
         @benchmark = ActBench.new
         bench_type = ActBenchType.find_by_id(b_type_ids[bnch])
         @benchmark.benchmark_type = bench_type.name.downcase
         @benchmark.act_bench_type_id = bench_type.id
         @benchmark.description = b_descripts[bnch]
         @benchmark.act_score_range_id = b_score_ids[bnch].to_i
         if params[:bench][:co_gle_id]
            @benchmark.co_gle_id = params[:bench][:co_gle_id]
         end
         @benchmark.standard = params[:standard]
         @benchmark.act_standard_id = params[:bench][:std_id]
         @benchmark.act_subject_id = params[:bench][:subj_id]
         @benchmark.act_master_id = params[:bench][:mstr_id]
         @benchmark.user_id = @current_user.id
         @benchmark.organization_id = @current_organization.id
         @benchmark.save
         if params[:gle_id]
          @gle = CoGle.find_by_id(params[:gle_id])
          end         
        end
       end
         redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
     end
    end
  end

  def edit_benchmark
  initialize_parameters
  if @benchmark.co_gle_id
    @gle = CoGle.find_by_id(@benchmark.co_gle_id)   
  end
    if request.post?

       if @benchmark.update_attributes params[:act_bench]
         flash[:notice] = "Benchmark Updated Successfully"       
        else
         flash[:error] = @benchmark.errors.full_messages.to_sentence 
       end
     end
  end

  def add_ifa_benchmark
  
  initialize_parameters

     @benchmark = ActBench.new
     unless params[:bench].nil?
      @current_subject = ActSubject.find_by_id(params[:bench][:subject_id])
      @benchmark.act_subject_id = @current_subject.id
      master = params[:bench][:master_id]=="" ? ActMaster.first : ActMaster.find_by_id(params[:bench][:master_id])
     else
      @benchmark.act_subject_id = @current_subject.id rescue ActSubject.first.id
      master = ActMaster.find_by_id(params[:master_id]) rescue ActMaster.first
     end
     @benchmark.act_master_id = @current_standard.id
     @benchmark.act_score_range_id = @current_standard.act_score_ranges.no_na.for_subject(@current_subject).first.id
     if params[:std_id]
       @benchmark.act_standard_id = ActStandard.find_by_id(params[:std_id]).id 
     else 
       @benchmark.act_standard_id = @current_standard.act_standards.for_subject(@current_subject).first.id rescue ActStandard.first.id
     end
     @benchmark.act_bench_type_id = @current_standard.act_bench_types.first.id rescue ActBenchType.first.id
     @benchmark.description = ""     
      if params[:gle_id]
        @benchmark.co_gle_id = params[:gle_id]
      end
     @benchmark.user_id = @current_user.id
     @benchmark.organization_id = @current_organization.id
     @benchmark.save
     redirect_to ifa_benchmark_edit_path(:organization_id => @current_organization, :benchmark_id => @benchmark)
  end

  def edit_ifa_benchmark
    initialize_parameters
    if @benchmark.co_gle_id
      @gle = CoGle.find_by_id(@benchmark.co_gle_id)
    end
    if request.post?
      unless params[:bench][:range_id] == ""
        @benchmark.act_score_range_id = params[:bench][:range_id].to_i
      end
      unless params[:bench][:standard_id]== ""
        @benchmark.act_standard_id = params[:bench][:standard_id].to_i
      end
      unless params[:bench][:type_id] == ""
        @benchmark.act_bench_type_id = params[:bench][:type_id].to_i
      end
      if @benchmark.update_attributes params[:act_bench]
         flash[:notice] = "Benchmark Updated Successfully"
      else
         flash[:error] = @benchmark.errors.full_messages.to_sentence
      end
    end
  end

  def destroy_benchmark
  
    initialize_parameters
    if @current_organization == @benchmark.organization || @current_user.ifa_admin_for_org?(@current_organization)
      @benchmark.destroy
      flash[:notice] = "Benchmark Deleted" 
    end
    redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
  end


#
#   QUESTIONS
#
  def subject_questions
  
  initialize_parameters

  end



  def list_standard_questions
  
  initialize_parameters
  
    @standard = ActStandard.find_by_id(params[:std_id]) rescue nil

  end
  
  def list_user_questions
    initialize_parameters
    render :partial => "question_pool_list", :locals => {:questions => @current_user.act_questions.order('updated_at DESC')}
  end 

  def add_question
  
  initialize_parameters
  
    @readings =@current_subject.act_rel_readings.sort_by{|r| r.label}.collect{|r| [r.label,r.id]}

    if params[:function]=="New"
      @question = ActQuestion.new
      @question.act_subject_id = @current_subject.id
    else

     if params[:function] == "Submit"
     @question = ActQuestion.new
     @question.act_subject_id = @current_subject.id
     @question.act_rel_reading_id = 0
     unless params[:q_read][:reading_id].empty?
       @question.act_rel_reading_id = params[:q_read][:reading_id]
     end     
     ready = true
      unless params[:question_type].empty?
        @question.question_type = params[:question_type]
      end
      @question.question = params[:quest][:question]
      @question.comment = params[:quest][:comment]
      @question.is_locked = false
      @question.is_calibrated = false
      @question.status = ""     
      @question.user_id = @current_user.id
      @question.organization_id = @current_organization.id
      @question.generation = 0
      @question.original_question_id = @question.id
      if @question.save
        unless params[:q_read][:reading_id].empty?
          @reading_text = ActQuestionReading.new
          @reading_text.reading = params[:quest][:reading]
          @question.act_question_reading = @reading_text
        end
        unless params[:q_range].empty?
        params[:q_range].each do |std,r|
          range = ActScoreRange.find_by_id(r.to_i)rescue nil
            if range
              current = @question.score_range(std)
              if current
              ActQuestionActScoreRange.destroy_all(["act_question_id = ? AND act_score_range_id = ?", @question.id, current.id])
              end
              unless range.upper_score==0
                @question.act_score_ranges << range
              end
            end

          end
        end       
        unless params[:q_std].empty?
        params[:q_std].each do |std,s|
          stand = ActStandard.find_by_id(s.to_i)rescue nil
            if stand
              current = @question.standard(std)
              if current
              ActQuestionActStandard.destroy_all(["act_question_id = ? AND act_standard_id = ?", @question.id, current.id])
              end
              @question.act_standards << stand
            end
         end 
        end
     @question.original_question_id = @question.id     
     @question.update_attributes params[:act_question]
#
#  Save Choices if MC 
     if @question.question_type == "MC"
        params[:choice_ans].each_with_index do |chc,index|
        unless chc.empty?
            @choice = @question.act_choices.new
            @choice.choice = chc
            @choice.position =  index + 1
            if params[:choice_check].include?(@choice.position.to_s)
               @choice.is_correct = true
                else
               @choice.is_correct = false
               end
            @choice.save
         end
        end
      end
    @benchmark_list = []  
    @question.act_score_ranges.each do |sr|
      @question.act_standards.each do |std|
     #   @benchmark_list += ActBench.find(:all, :conditions => ["act_subject_id = ? AND act_score_range_id = ? AND act_standard_id = ?", @question.act_subject_id, sr.id, std.id]) rescue nil
        @benchmark_list += @question.act_subject.act_benches.for_scorerange_strand(sr, std)
      end
    end
     @benchmark_list.each do |bench|    
       @question.act_benches<<bench
     end
     redirect_to ifa_question_show_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question)
    end 
    flash[:error] = @question.errors.full_messages.to_sentence 
    end 
   end
 end

 
  def edit_question
  
    initialize_parameters

#    @rel_readings = ActRelReading.find(:all, :conditions => ["act_subject_id = ?", @question.act_subject_id], :order => "label").collect{|r| [r.label,r.id]}
    @rel_readings = @question.act_subject.act_rel_readings.sort_by{|r| r.label}.collect{|r| [r.label,r.id]}
    if @question.act_rel_reading_id == 0
      @reading_label = "* * No Reading * *"
      @question_reading = " "
    else
      @reading_label = "* * Current Question Reading * *"
      @question_reading = @question.act_question_reading.reading
      @rel_readings = @rel_readings.insert(0,["* * Remove Reading * *", 0])
    end

    @mastery_range = @question.act_score_ranges.for_standard(@current_standard).first rescue nil
    @strand = @question.act_standards.for_standard(@current_standard).first rescue nil

    if params[:function] == "Submit"
      unless params[:reading][:reading_id].empty? && !@question.act_question_reading
        if @question.act_question_reading
          if params[:reading][:reading_id] == "0"
#          Remove Existing Reading and Update Master Reading ID
            @question.act_question_reading.delete
            @question.act_rel_reading_id = params[:reading][:reading_id]            
          else
#          Update Existing Reading and Master Reading ID
            @question.act_question_reading.update_attributes(:reading => params[:quest][:reading]) 
            @question.act_rel_reading_id = params[:reading][:reading_id] unless params[:reading][:reading_id].empty?
          end
        else
#       Add New Reading And Update Master Reading ID  (THIS IS NOT PROPER)
          @reading_text = ActQuestionReading.new
          @reading_text.reading = params[:quest][:reading]
          @question.act_question_reading = @reading_text
          @question.act_rel_reading_id = params[:reading][:reading_id]
        end
      end

      unless params[:q_range][:act_score_range_id].empty?
        existing_range = @question.act_score_ranges.for_standard(@current_standard).first rescue nil
        new_range = ActScoreRange.find_by_id(params[:q_range][:act_score_range_id])
        if existing_range
          @question.act_score_ranges.delete existing_range
        end
        unless @question.act_score_ranges.include?(new_range) 
          @question.act_score_ranges << new_range
        end            
      end 
 
      unless params[:q_std][:act_standard_id].empty?
        existing_strand = @question.act_standards.for_standard(@current_standard).first rescue nil
        new_strand = ActStandard.find_by_id(params[:q_std][:act_standard_id])
        if existing_strand
          @question.act_standards.delete existing_strand
        end
        unless @question.act_standards.include?(new_strand) 
          @question.act_standards << new_strand
        end            
      end 
 
   
#
# Check For Choices

       update_choices if params[:act_choices]
       if @question.act_choices.size > 0
         @question.question_type = "MC"
       else
         @question.question_type = "SA"         
       end
       if @question.update_attributes params[:act_question]
#
# Adjust Assessment ranges If Necessary
      @question.act_assessments.each do |ass|
        if (@question.upper_score(@current_standard) > ass.upper_score(@current_standard)) || (@question.lower_score(@current_standard) < ass.lower_score(@current_standard))
          ActAssessmentScoreRange.destroy_all(["act_assessment_id = ? AND act_master_id = ?", ass.id, @current_standard.id])rescue nil
          range = ActAssessmentScoreRange.new
          range.upper_score = ass.max_question_score(@current_standard)
          range.lower_score = ass.min_question_score(@current_standard)
          range.act_assessment_id = ass.id
          range.act_master_id = @current_standard.id
          range.standard = @current_standard.abbrev.downcase
          range.save
        end
      end

         flash[:notice] = "Question Updated Successfully"       
         redirect_to ifa_question_show_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question)
        else
         flash[:error] = @question.errors.full_messages.to_sentence 
       end
    unless params[:res_check].nil?  
    bench_list = []
    params[:res_check].each do |b|
      bench = ActBench.find_by_id(b)rescue nil
        unless bench.nil?
        bench_list<<bench
        end
      end
    bench_list.uniq.each do |benchmark|    
      if @question.act_benches.include?(benchmark) 
        then
           @question.act_benches.delete benchmark
        else
           @question.act_benches<<benchmark
        end
      end 
    end
    end
  @benchmark_list = []
  @tagged_benches = @question.act_benches.sort_by{|b| [b.benchmark_type]}
  # @benchmark_list += ActBench.find(:all, :conditions => ["act_subject_id = ? AND act_score_range_id = ? AND act_standard_id = ?", @question.act_subject_id, @question.score_range(@current_standard).id, @question.standard(@current_standard).id]) rescue nil
    @benchmark_list += @question.act_subject.act_benches.for_scorerange_strand( @question.score_range(@current_standard), @question.standard(@current_standard))
    @untagged_benches = (@benchmark_list - @tagged_benches)
  end

 
  def add_ifa_question
  
  initialize_parameters

     @question = ActQuestion.new
     unless params[:quest].nil?
      @question.act_subject_id = ActSubject.find_by_id(params[:quest][:subject_id]).id rescue ActSubject.first.id
     else
      @question.act_subject_id = @current_subject.id
     end
   #  @readings = ActRelReading.find(:all, :conditions => ["act_subject_id = ?", @question.act_subject_id], :order => "label").collect{|r| [r.label,r.id]}
      @readings = @question.act_subject.act_rel_readings.sort_by{|r| r.label}.collect{|r| [r.label,r.id]}
      @question.act_rel_reading_id = 0
      @question.question_type = "SA"
      @question.question = '* * New Question * *'
      @question.is_active = false
      @question.is_locked = false
      @question.is_calibrated = false
      @question.user_id = @current_user.id
      @question.organization_id = @current_organization.id
      @question.generation = 0
      if @question.save
        @question.update_attributes(:original_question_id => @question.id)
      end
     redirect_to ifa_question_edit_path(:organization_id => @current_organization, :assessment_id => @assessment, :question_id => @question, :function => "Edit")
 end

 	def edit_ifa_question
  
    initialize_parameters

   if params[:function] == "Submit"
     unless @question.is_locked
     unless params[:reading][:reading_id].empty? && !@question.act_question_reading
       if @question.act_question_reading
         if params[:reading][:reading_id] == "0"
            @question.act_question_reading.delete
            @question.act_rel_reading_id = params[:reading][:reading_id]            
         else
            @question.act_question_reading.update_attributes(:reading => params[:quest][:reading]) 
            @question.act_rel_reading_id = params[:reading][:reading_id] unless params[:reading][:reading_id].empty?
         end
       else
          @reading_text = ActQuestionReading.new
          @reading_text.reading = params[:quest][:reading]
          @question.act_question_reading = @reading_text
         @question.act_rel_reading_id = params[:reading][:reading_id]
       end
     end
     @question.is_active = true
       if @question.update_attributes params[:act_question]
         if @assessment
           @assessment.act_questions<<@question unless @assessment.act_questions.include?(@question)
           @assessment.calibrate
           @assessment.check_lock
           @assessment.set_min_and_max
           flash[:notice] = "Question Updated. Added To Assessment, #{@assessment.name}"
           @assessment = nil
           else
         flash[:notice] = "Question Updated"             
         end
         
     
       else
         flash[:error] = @question.errors.full_messages.to_sentence 
       end
    else
           flash[:error] = "Updates Not Made. Question Locked."     
    end
   end
  # @rel_readings = ActRelReading.find(:all, :conditions => ["act_subject_id = ?", @question.act_subject_id], :order => "label").collect{|r| [r.label,r.id]}
    @rel_readings = @question.act_subject.act_rel_readings.sort_by{|r| r.label}.collect{|r| [r.label,r.id]}
    if @question.act_rel_reading_id == 0
     @reading_label = "* * No Related Content * *"
     @question_reading = " "
   else
     @reading_label = "* * Current Related Content * *"
     @question_reading = @question.act_question_reading.reading
     @rel_readings = @rel_readings.insert(0,["* * Remove Related Content * *", 0])
   end
   @resource_list = []
   @master = @current_provider.ifa_org_option.act_masters.first rescue nil
   unless @master
     @master = ActMaster.default_std
   end 
 
 end

  def remove_choice
    choice = ActChoice.find(params[:id])
    ActChoice.destroy(choice)
    render :text => "successful"
  end


  def copy_question
  
    initialize_parameters
    

    if @question
      @new_question = ActQuestion.new
      @new_question = @question.clone
      @new_question.is_locked = false
      @new_question.created_at = Time.now
      @new_question.updated_at = Time.now
      @new_question.user_id = @current_user.id
      @new_question.organization_id = @current_organization.id
      @new_question.generation += 1
      @question.act_benches.each do |b|
        @new_question.act_benches<<b
      end
      @question.act_standards.each do |s|
        @new_question.act_standards<<s
      end
      @question.act_score_ranges.each do |r|
        @new_question.act_score_ranges<<r
      end
       if @new_question.save
          flash[:notice] = "Question Copied Successfully"  
          @question.act_choices.each do |c| 
            new_choice = @new_question.act_choices.new
            new_choice = c.clone
            new_choice.act_question_id = @new_question.id
            new_choice.created_at = Time.now
            new_choice.updated_at = Time.now 
            new_choice.save
          end
          if @question.act_question_reading
            new_read = ActQuestionReading.new
            new_read.act_question_id = @new_question.id
            new_read.reading = @question.act_question_reading.reading
            new_read.save
          end
          @question = ActQuestion.find_by_id(@new_question.id)
        else
         flash[:error] = @new_question.errors.full_messages.to_sentence 
       end
     end
   redirect_to ifa_question_show_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question)
  end

  def unlock_question
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    if params[:classroom_id]
      @classroom = params[:classroom_id] ? Classroom.find_by_public_id(params[:classroom_id]) : @current_organization.classrooms.active.first 
    end
    @question = ActQuestion.find_by_public_id(params[:question_id])
    if @question.is_locked
      @question.is_locked = false
    else
      @question.is_locked = true
    end
    @question.update_attributes params[:act_question]
    redirect_to ifa_question_show_path(:organization_id => @current_organization, :classroom_id => @classroom, :question_id => @question)
  end

  def preview_question
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil  
    @question = ActQuestion.find_by_public_id(params[:question_id])rescue nil
    render :layout => "act_assessment"
  end

#
#   READINGS
#
  def subject_readings
  
    initialize_parameters
    @reading_list = @current_subject.act_rel_readings
    @reading_list.sort!{|a,b| a.act_genre.name <=> b.act_genre.name}
    render layout: false
  end

  def genre_readings
  
    initialize_parameters
  
 #   @reading_list = ActRelReading.find(:all, :conditions => ["act_genre_id = ? AND act_subject_id =?", params[:genre_id], @current_subject.id]) rescue nil
    @reading_list = @current_subject.act_rel_readings.where('act_genre_id = ?', params[:genre_id].to_i)
    @reading_list = @reading_list.sort_by{|a| [a.act_subject.name]}
  end

  def add_reading
  
    initialize_parameters
  
    if params[:function]=="New"
      @reading = ActRelReading.new
      @reading.reading = "-- Type or Paste Reading Here --"
      @reading.label = ""
     if (params[:read] && params[:read][:subject_id] && params[:read][:subject_id] != "")
      @reading.act_subject_id = ActSubject.find_by_id(params[:read][:subject_id]).id rescue ActSubject.first.id
     elsif params[:subject_id]
       @reading.act_subject_id = ActSubject.find_by_id(params[:subject_id]).id rescue ActSubject.first.id
     else
      @reading.act_subject_id = ActSubject.first.id
     end      
    else
     if params[:function] == "Submit"
     @reading = ActRelReading.new
     @reading.act_subject_id = @current_subject.id
     @reading.label = params[:rdg][:label]
     @reading.reading = params[:rdg][:reading]
     @reading.act_genre_id = params[:rdg][:act_genre_id]
     @reading.user_id = @current_user.id
     @reading.organization_id = @current_organization.id
    end
    if @reading.save
      flash[:notice] = "Related Reading Saved"   
      unless params[:range][:act_score_range_id].empty?
        range = ActScoreRange.find_by_id(params[:range][:act_score_range_id])rescue nil
        if range
           ActRelReadingActScoreRange.destroy_all(["act_rel_reading_id = ? AND act_master_id = ?", @reading.id, range.act_master_id])
          unless range.upper_score==0
            rdg_range = ActRelReadingActScoreRange.new
            rdg_range.act_rel_reading_id = @reading.id
            rdg_range.act_master_id = range.act_master_id
            rdg_range.act_score_range_id = range.id
            rdg_range.save
          end
         end
        end 
      redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
    end 
    flash[:error] = @reading.errors.full_messages.to_sentence 
   end
  end

  def edit_reading
  
    initialize_parameters
  

    if request.post?

       unless params[:reading][:act_genre_id].empty?
         @reading.act_genre_id = params[:reading][:act_genre_id]
       end       
   
       if @reading.update_attributes params[:act_rel_reading]
         flash[:notice] = "Related Reading Updated Successfully"  
                
      unless params[:range][:act_score_range_id].empty?
        range = ActScoreRange.find_by_id(params[:range][:act_score_range_id])rescue nil
        if range
           ActRelReadingActScoreRange.destroy_all(["act_rel_reading_id = ? AND act_master_id = ?", @reading.id, range.act_master_id])
          unless range.upper_score==0
            rdg_range = ActRelReadingActScoreRange.new
            rdg_range.act_rel_reading_id = @reading.id
            rdg_range.act_master_id = range.act_master_id
            rdg_range.act_score_range_id = range.id
            rdg_range.save
          end
         end
        end 
        else
         flash[:error] = @reading.errors.full_messages.to_sentence 
       end
       redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
    end
  end

  def destroy_reading
  
    initialize_parameters
  
    reading = ActRelReading.find_by_public_id(params[:reading_id])
     if @current_user == reading.user || @current_user.ifa_admin_for_org?(@current_organization)
      reading.destroy
      flash[:notice] = "Related Reading Deleted"
     end
    redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
  end


#
#   IFA Dashboard Update Actions
#

  def manual_ifa_update

# Temporary De-active

    if params[:update] == "xxx"  
      period_end  = Date.today.at_end_of_month - params[:periods].to_i.months 
      entity_class = params[:entity_class].to_s
      question_log = IfaQuestionLog.for_period(period_end)
      uniq_subjects = question_log.collect{|ql| ql.act_subject}.uniq
      submissions = question_log.collect{|ql| ql.act_submission}.uniq
      if entity_class == "User"
        uniq_entities = question_log.collect{|ql| ql.user}.uniq
        elsif entity_class == "Classroom"
          uniq_entities = question_log.collect{|ql| ql.classroom}.uniq
          elsif entity_class == "Organization"    
            uniq_entities = question_log.collect{|ql| ql.organization}.uniq    
            else
              uniq_entities = []
      end
      uniq_subjects.each do |subj|
        uniq_entities.each do |entity|
            if entity_class == "User"
              submission_ids = IfaQuestionLog.for_user(entity).for_subject(subj).for_period(period_end).collect{|ql| ql.act_submission_id}.uniq rescue []
              elsif entity_class == "Classroom"
                submission_ids = IfaQuestionLog.for_classroom(entity).for_subject(subj).for_period(period_end).collect{|ql| ql.act_submission_id}.uniq rescue []
                  else entity_class == "Organization"    
                     submission_ids = IfaQuestionLog.for_organization(entity).for_subject(subj).for_period(period_end).collect{|ql| ql.act_submission_id}.uniq rescue []
             end
            entity_dashboard = entity.ifa_dashboard.for_subject(subject).for_period(period_end).first rescue nil
            if entity_dashboard
                entity_dashboard.destroy
            end
            submission_ids.each do |sid|
              @submission = ActSubmission.find_by_id(sid) rescue nil
              if  !@submission.nil?
                @submission.dashboard_it(entity_class)
              end
            end       
        end        
     end   # end subject loop       
  end
    render :layout => "master"
  end

#
#   AJAX Actions

  def submission_teacher
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   @teacher_list = @classroom.teachers_for_student(@current_user).sort{|a,b| a.last_name.downcase <=> b.last_name.downcase} rescue []
   @teacher = User.find_by_id(params[:teacher_id]) rescue nil
    render :partial => "submit_assessment_button"  
 end

  def update_classroom_assessment_pool
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   ass = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   @tagged_classroom = Classroom.find_by_public_id(params[:tagged_classroom_id]) rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   if @classroom
     if @classroom.act_assessments.include?(ass) 
       @classroom.act_assessments.delete ass
     else
        @classroom.act_assessments<< ass
     end
    end
  render :partial => "ifa_classroom_assessment_assignment"  
 end

  def update_classroom_assessment_pool_from_repository
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   ass = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   if @classroom
     if @classroom.act_assessments.include?(ass) 
       @classroom.act_assessments.delete ass
     else
        @classroom.act_assessments<< ass
     end
    end
   # get_assessments_from_repository
   @assessment_pool = ActAssessment.active.sort!{|a,b| b.updated_at <=> a.updated_at}
  render :partial => "ifa_classroom_assessment_assignment_repository"  
 end

  def static_assess_question_analysis
   initialize_parameters
   @q = ActQuestion.find_by_id(params[:q_id])
  end
  def question_analysis_test
    initialize_parameters
    @q = ActQuestion.find_by_id(params[:q_id])
  end


  def static_assess_user_options_update
   initialize_parameters
    if params[:begin_date]
      window_start = DateTime.parse(params[:begin_date]).strftime("%Y-%m-%d")
      @current_user.ifa_user_option.update_attributes(:beginning_period=> window_start)
    end
    if params[:filter] == 'student'
      @current_user.ifa_user_option.update_attributes(:is_student_filtered=> !@current_user.ifa_user_option.is_student_filtered,:is_org_filtered=> false, :is_classroom_filtered=> false,:is_colleague_filtered=> false)
    end
    if params[:filter] == 'classroom'
      @current_user.ifa_user_option.update_attributes(:is_classroom_filtered=> !@current_user.ifa_user_option.is_classroom_filtered,:is_org_filtered=> false, :is_student_filtered=> false,:is_colleague_filtered=> false)
    end
    if params[:filter] == 'colleague'
      @current_user.ifa_user_option.update_attributes(:is_colleague_filtered=> !@current_user.ifa_user_option.is_colleague_filtered,:is_org_filtered=> false, :is_student_filtered=> false,:is_classroom_filtered=> false)
    end
    if params[:filter] == 'org'
      @current_user.ifa_user_option.update_attributes(:is_org_filtered=> !@current_user.ifa_user_option.is_org_filtered,:is_classroom_filtered=> false, :is_student_filtered=> false,:is_colleague_filtered=> false)
    end    
    render :partial => "static_assessment_user_options"
  end

 def edit_assessment_sequence
   initialize_parameters 
   questions = @assessment.act_assessment_act_questions.sort_by{|q| q.position} rescue []
   questions.each_with_index do|aq,idx|
   if aq.act_question_id == params[:question_id].to_i
      if params[:direction]=="up" && idx>0
          base_position = aq.position
          aq.update_attributes(:position => questions[idx-1].position)
          questions[idx-1].update_attributes(:position => base_position)
       end
      if params[:direction]=="down" && (idx+1)<questions.size
          base_position = aq.position
          aq.update_attributes(:position => questions[idx+1].position)
          questions[idx+1].update_attributes(:position => base_position)
       end  
    end
   end
  @assessment.sequence_questions
  render :partial => "ifa_assessment_questions_update"  
 end

  def edit_assessment_question_pool_recycle
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   render :partial => "ifa_assessment_options" 
 end

  def classroom_get_filtered_assessments
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    if @classroom
      get_assessments_from_repository
    end
  render :partial => "ifa_classroom_assessment_assignment_repository"  
  end

  def classroom_option_toggle_calibrate
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   if @classroom.ifa_classroom_option
     @classroom.ifa_classroom_option.update_attributes(:is_calibrated =>!@classroom.ifa_classroom_option.is_calibrated)
   end
    render :partial => "ifa_classroom_filter_options"
  end

  def classroom_option_toggle_user_filter
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   if @classroom.ifa_classroom_option
     @classroom.ifa_classroom_option.update_attributes(:is_user_filtered =>!@classroom.ifa_classroom_option.is_user_filtered)
   end
    render :partial => "ifa_classroom_filter_options"
  end

  def classroom_options_update
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
   new_master = ActMaster.find_by_id(params[:master_id]) rescue nil
   new_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
   if @classroom.ifa_classroom_option
     if new_master
      @classroom.ifa_classroom_option.update_attributes(:act_master_id => new_master.id)
     end
     if new_subject
      @classroom.ifa_classroom_option.update_attributes(:act_subject_id => new_subject.id)
     end
     if params[:subject_id] == "All Subjects"
      @classroom.ifa_classroom_option.update_attributes(:act_subject_id => nil)
     end
     if params[:score]
       if params[:score] == "All"
       @classroom.ifa_classroom_option.update_attributes(:max_score_filter => nil)
       else
       @classroom.ifa_classroom_option.update_attributes(:max_score_filter => params[:score])      
       end
     end
   end
   @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    render :partial => "ifa_classroom_filter_options"
  end


  def user_option_toggle_calibrate
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   if @current_user.ifa_user_option
     @current_user.ifa_user_option.update_attributes(:is_calibrated =>!@current_user.ifa_user_option.is_calibrated)
   end
    render :partial => "ifa_assessment_options"
  end

  def user_option_toggle_user_filter
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   if @current_user.ifa_user_option
     @current_user.ifa_user_option.update_attributes(:is_user_filtered =>!@current_user.ifa_user_option.is_user_filtered)
   end
    render :partial => "ifa_assessment_options"
  end

  def user_options_update
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   new_master = ActMaster.find_by_id(params[:master_id]) rescue nil
   new_strand = ActStandard.find_by_id(params[:strand_id]) rescue nil
   new_range = ActScoreRange.find_by_id(params[:range_id]) rescue nil
   new_read = ActRelReading.find_by_id(params[:reading_id]) rescue nil
   if @current_user.ifa_user_option
     if new_master
      @current_user.ifa_user_option.update_attributes(:act_master_id => new_master.id)
     end
     if new_strand
      @current_user.ifa_user_option.update_attributes(:act_standard_id => new_strand.id)
     end
     if new_range
      @current_user.ifa_user_option.update_attributes(:act_score_range_id => new_range.id)
     end
     if new_read
      @current_user.ifa_user_option.update_attributes(:act_rel_reading_id => new_read.id)
     end
     if params[:range_id]== "no filter"
      @current_user.ifa_user_option.update_attributes(:act_score_range_id => nil) 
     end
     if params[:strand_id]== "no filter"
       @current_user.ifa_user_option.update_attributes(:act_standard_id => nil) 
     end
     if params[:reading_id]== "no filter"
       @current_user.ifa_user_option.update_attributes(:act_rel_reading_id => nil) 
     end
   end
    render :partial => "ifa_assessment_options"
  end

  def edit_assessment_add_question
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   @question = ActQuestion.find_by_id(params[:question_id]) rescue nil
    if @question && !@assessment.is_locked
        unless @assessment.act_questions.include?(@question) 
          @assessment.act_questions<<@question
          @assessment.calibrate
          @assessment.check_lock
          @assessment.set_min_and_max
        end
     end
  render :partial => "ifa_assessment_questions_update"  
 end
 
  def edit_assessment_remove_question
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   @question = ActQuestion.find_by_id(params[:question_id]) rescue nil
    if @question && !@assessment.is_locked
        if @assessment.act_questions.include?(@question) 
          @assessment.act_questions.delete @question
          @assessment.calibrate
          @assessment.set_min_and_max
          @assessment.sequence_questions
        end
     end
  render :partial => "ifa_assessment_questions_update"   
end

 def edit_assessment_toggle_lock
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
    if @assessment
      @assessment.update_attributes(:is_locked =>!@assessment.is_locked)
      @assessment.calibrate
    end
   render :partial => "ifa_assessment_questions_update"
 end

 def position_question
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   position = params[:position].to_i
   if @assessment && question && (position > 0)
      @assessment.reposition_question(question, position)
   end
   render :partial => "ifa_assessment_questions_update"
 end
  
 def edit_assessment_toggle_active
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
    if @assessment
      @assessment.update_attributes(:is_active =>!@assessment.is_active)
    end
    @assessment = ActAssessment.find_by_public_id(params[:assessment_id]) rescue nil
   render :partial => "ifa_assessment_questions_update"  
 end
 
  def edit_assessment_destroy_assessment
  initialize_parameters
    if @assessment.act_submissions.empty? && !@assessment.is_locked 
      if @current_user == @assessment.user || @current_user.ifa_admin_for_org?(@current_organization)
        @assessment.destroy
        flash[:notice] = "Assessment Deleted" 
      end
    else
     flash[:error] = "assessment Was Not Deleted"
    end
    redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
  end 


  def toggle_question_calibration
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   if @question
     @question.update_attributes(:is_calibrated =>!@question.is_calibrated)
     @question.calibrate_assessments
   end
    render :partial => "static_question_options"
  end

  def edit_question_new_master
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @master = ActMaster.find(params[:master_id]) rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   unless @master
     @master = ActMaster.default_std
   end
     render :partial => "ifa_question_master_update"  
  end

  def edit_question_score_range
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   
   if @master && @question && !@question.is_locked
     existing_ranges = @question.act_score_ranges.for_standard(@master).first rescue nil
     new_range = ActScoreRange.find_by_id(params[:range_id]) rescue nil
     if existing_ranges
       @question.act_score_ranges.delete existing_ranges
     end
     unless @question.act_score_ranges.include?(new_range) 
       @question.act_score_ranges << new_range
     end
   adjust_assessment_ranges
   end   
   render :partial => "ifa_question_master_update"  
  end


  def edit_question_strand
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
   @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
   @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
   if @master && @question && !@question.is_locked
     existing_strands = @question.act_standards.for_standard(@master) rescue nil
     new_strand = ActStandard.find_by_id(params[:strand_id])
     if existing_strands
       @question.act_standards.delete existing_strands
     end
     unless @question.act_standards.include?(new_strand) 
       @question.act_standards << new_strand
     end
   end
   render :partial => "ifa_question_master_update"  
  end


  def edit_student_baseline_score

  initialize_parameters
      @student = User.find_by_public_id(params[:student_id])rescue nil
      @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
      @subject = ActSubject.find_by_public_id(params[:subject_id]) rescue nil
      @lower_score = params[:score] rescue nil
    unless @student && @master && @subject && @lower_score
       redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
    end
    baseline_score = @student.ifa_user_baseline_scores.for_subject(@subject).for_standard(@master).first rescue nil
    if baseline_score
      if @lower_score == "0"
        baseline_score.destroy
      else
        baseline_score.update_attributes(:score => @lower_score)
      end
    else
      unless @lower_score == "0"
        baseline_score = IfaUserBaselineScore.new
        baseline_score.user_id = @student.id
        baseline_score.act_master_id = @master.id
        baseline_score.act_subject_id = @subject.id
        baseline_score.score = @lower_score
        baseline_score.save
      end
    end
      render :partial => "student_baseline_scores" 
  end

  def edit_student_grade_level

  initialize_parameters
      @student = User.find_by_public_id(params[:student_id])rescue nil
      base_date = @current_organization.school_begin_date ? @current_organization.school_begin_date : Date.today
      if @student.student_demographic
        @student.student_demographic.update_attributes(:grade_base_date => base_date,:grade_level_base => params[:grade].to_i)
      else
        new_demographic = StudentDemographic.new
        new_demographic.grade_level_base = params[:grade].to_i
        new_demographic.grade_base_date = base_date 
        @student.student_demographic = new_demographic
      end
      render :partial => "student_demographics" 
  end

  def edit_student_csap_demographic

  initialize_parameters
      @student = User.find_by_public_id(params[:student_id])rescue nil
      @subject = ActSubject.find_by_public_id(params[:subject_id]) rescue nil
      @lower_score = params[:score] rescue nil
    unless @student && @subject && @lower_score
       redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
    end
    subject_demo = @student.student_subject_demographics.for_subject(@subject).first rescue nil
    if subject_demo
      if @lower_score == "0"
        subject_demo.update_attributes(:latest_csap => nil)
      else
        subject_demo.update_attributes(:latest_csap => @lower_score)
      end
    else
      unless @lower_score == "0"
        subject_demo = StudentSubjectDemographic.new
        subject_demo.user_id = @student.id
        subject_demo.act_subject_id = @subject.id
        subject_demo.latest_csap = @lower_score
        subject_demo.save
      end
    end
      render :partial => "student_baseline_scores" 
  end

  def edit_question_update_choice
   @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
    @question = ActQuestion.find_by_public_id(params[:question_id]) rescue nil
    choice_text = params[:choice]
    position = params[:position].to_i rescue 1
    if @question && !@question.is_locked
      ActChoice.find_by_id(params[:choice_id]).update_attributes(:position => position, :choice => choice_text) rescue nil
    end
   render :partial => "ifa_question_choices_update"  
  end


  def edit_question_add_choice
   
    initialize_parameters

    @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
    choice_text = params[:choice]
    position = params[:position].to_i rescue 1
    if choice_text && @question && !@question.is_locked
      @choice = @question.act_choices.new
      @choice.choice = choice_text
      @choice.is_correct = false
      @choice.position
      @choice.position = position
      @choice.save
    end
    @question.update_attributes(:question_type => "MC")
   render :partial => "ifa_question_choices_update"  
 end
 
  def edit_question_remove_choice
   
    initialize_parameters

    @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
    @choice = ActChoice.find_by_id(params[:choice_id]) rescue nil
    if @choice && !@question.is_locked
      ActChoice.destroy(@choice)
    end
    if @question.act_choices.empty?
      @question.update_attributes(:question_type => "SA")
    end
   render :partial => "ifa_question_choices_update"  
 end
 
  def edit_question_remove_benchmark
   
    initialize_parameters

     bench = ActBench.find_by_id(params[:benchmark_id])rescue nil
     if bench && @question.act_benches.include?(bench) 
           @question.act_benches.delete bench
      end
   render :partial => "ifa_question_benchmarks"  
 end
 
  def edit_question_add_benchmark
   
    initialize_parameters

    bench = ActBench.find_by_id(params[:benchmark_id])rescue nil
     if bench && !@question.act_benches.include?(bench) 
           @question.act_benches<<bench
      end
   render :partial => "ifa_question_benchmarks"  
 end         
      
 
  def edit_question_attach_assessment
   
    initialize_parameters

    @assessment = ActAssessment.find_by_id(params[:assessment_id])rescue nil
     unless @assessment.act_questions.include?(@question) 
        @assessment.act_questions<<@question
        @assessment.calibrate
        @assessment.check_lock
        @assessment.set_min_and_max
    end
   render :partial => "ifa_question_assessments"  
 end         
  
  def edit_question_remove_assessment
   
    initialize_parameters

    assessment = ActAssessment.find_by_id(params[:assessment_id])rescue nil
    if assessment.act_questions.include?(@question) 
        assessment.act_questions.delete @question
        assessment.calibrate
        assessment.check_lock
        assessment.set_min_and_max
    end
   render :partial => "ifa_question_assessments"  
 end         
 
 def edit_question_find_resources
   
    initialize_parameters

   @group = params[:group_type]
   find_fav_group_resources
   render :partial => "ifa_question_resource"  
 end              

  def edit_question_attach_resource
   
    initialize_parameters

    @group = params[:group_type]
    if @question
     @question.update_attributes(:content_id => params[:resource_id].to_i)
    end    
    find_fav_group_resources
    render :partial => "ifa_question_resource"  
 end

  def edit_question_remove_resource
   
    initialize_parameters

   @group = params[:group_type]
   if @question
     @question.update_attributes(:content_id => nil)
   end
    if @group == 'VIDEO'
      @resource_list = @current_user.favorite_resources rescue []
    else
      @resource_list = @current_user.favorite_resources rescue []
    end
   render :partial => "ifa_question_resource"  
 end
  def edit_question_assessments_recycle
   
   initialize_parameters

   render :partial => "ifa_question_assessments" 
 end

  def edit_question_benchmarks_recycle
   
    initialize_parameters

    render :partial => "ifa_question_benchmarks" 
 end
 
  def edit_question_options_recycle
   
    initialize_parameters

    render :partial => "ifa_question_options" 
 end
          
  def edit_question_toggle_lock
   
    initialize_parameters

     if @question 
      if @question.question_type == 'SA' || (@question.question_type == 'MC' && @question.act_choices.correct.size > 0)
        @question.update_attributes(:is_locked =>!@question.is_locked)
      end
    end
   render :partial => "ifa_question_options"
 end

  def edit_question_picture_enlarge
   
    initialize_parameters

    if @question 
        @question.update_attributes(:is_enlarged =>!@question.is_enlarged)
    end
   render :partial => "ifa_question_options"
 end

  
 def edit_question_toggle_active
   
    initialize_parameters

    if @question
      @question.update_attributes(:is_active =>!@question.is_active)
    end
   render :partial => "ifa_question_options"  
 end
 
  def edit_question_destroy_question
    
    initialize_parameters
    if @question.act_answers.empty? && @question.act_assessments.empty? && !@question.is_locked
      if @current_user == @question.user || @current_user.ifa_admin_for_org?(@current_organization)
        @question.destroy
        flash[:notice] = "Assessment Question Deleted" 
      end
    else
     flash[:error] = "Question Was Not Deleted"
    end
    redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
  end  
 
  def edit_question_toggle_choice
    initialize_parameters
    @master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
    @choice = ActChoice.find_by_id(params[:choice_id]) rescue nil
    if @choice && !@question.is_locked
      @choice.update_attributes(:is_correct =>!@choice.is_correct)
    end
   render :partial => "ifa_question_choices_update"  
  end

  def add_remove_app_option_master
    @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    @current_user = User.find_by_public_id(params[:user_id]) rescue nil    
    master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
    if params[:function]== "add"
      @current_provider.ifa_org_option.act_masters << master
    else
      remove_masters = @current_provider.ifa_org_option.ifa_org_option_act_masters.for_master(master) rescue nil
      remove_masters.each do|m|
        m.destroy
      end
    end
    render :partial => "manage_options_ifa_masters"
   end

  def select_related_reading
    readings = ActRelatedReading.auto_complete_on params[:q]
    render :text => readings.empty? ? "" : readings.collect{|rdg| "#{rdg.label}\n"}
  end

  def get_related_reading
    rel_reading = ActRelReading.find_by_id(params[:id])rescue nil
    if rel_reading
      reading_text = "<span style='vertical-align:center'><strong><u>" + rel_reading.label.titleize + "</u></strong></center><br/>" + rel_reading.reading
    else
      reading_text = " "
    end
   
    render :text => reading_text
  end

  def get_question_reading
    question = ActQuestion.find_by_id(params[:id])rescue nil
    if question
      reading_text = question.act_question_reading.reading
    else
      reading_text = "Reading Text Not Found "
    end
   
    render :text => reading_text
  end
  
  def toggle_ifa_dashboard
    initialize_parameters
    @current_user.update_attributes(:calibrated_only =>!@current_user.calibrated_only)
    start_period = params[:start_period].to_date rescue @options.begin_school_year
    end_period = params[:end_period].to_date rescue Date.today
    @entity = @current_organization
    if params[:class] == "Organization"
      @entity = Organization.find_by_public_id(params[:entity_id])rescue @current_organization
    end
    if params[:class] == "Classroom"
      @entity = Classroom.find_by_public_id(params[:entity_id])rescue nil
    end    
    if params[:class] == "User"
      @entity = User.find_by_public_id(params[:entity_id])rescue @current_user
    end      
    prepare_ifa_dashboard(@entity, start_period, end_period)
    @toggle_filter = "toggle_filter"
    render :partial => "/apps/assessment/ifa_dashboard_with_toggle"
  end

  def toggle_sumry_ifa_dashboard
    initialize_parameters
    @current_user.update_attributes(:calibrated_only =>!@current_user.calibrated_only)
    prepare_summary_dashboard   
    render :partial => "/apps/assessment/ifa_summary_dashboard"
  end

   def toggle_sumry_ifa_data
     initialize_parameters
     @current_user.update_attributes(:calibrated_only =>!@current_user.calibrated_only)
     prepare_summary_data
     render :partial => "/apps/assessment/ifa_user_views"
   end

  def toggle_sat_view
    initialize_parameters
    toggle_user_sat(@current_user)
    prepare_summary_data
    render :partial => "/apps/assessment/ifa_user_views"
   # redirect_to self.send(@current_application.link_path,{:organization_id => @current_organization, :classroom_id => @classroom})
  end

  def toggle_sat_view_student
    initialize_parameters
    toggle_user_sat(@current_user)
    redirect_to ifa_assessment_take_path(:organization_id => @current_organization,:classroom_id => @classroom, :topic_id => @topic)
  end

   private

  def toggle_user_sat(user)
    user.ifa_user_option.update_attributes(:sat_view =>!user.ifa_user_option.sat_view)
  end


   def ifa_allowed?
     current_app_enabled_for_current_org?
   end
 
 def get_assessments_from_repository
 
  @assessment_pool = []
  if @classroom.ifa_classroom_option
    if @classroom.ifa_classroom_option.is_calibrated && @classroom.ifa_classroom_option.is_user_filtered && @classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = @current_user.act_assessments.where('is_active AND is_calibrated AND act_subject_id = ?', @classroom.ifa_classroom_option.act_subject.id)
    end
    if @classroom.ifa_classroom_option.is_calibrated && @classroom.ifa_classroom_option.is_user_filtered && !@classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = @current_user.act_assessments.active.calibrated
    end
    if !@classroom.ifa_classroom_option.is_calibrated && @classroom.ifa_classroom_option.is_user_filtered  && @classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = @current_user.act_assessments.active.where('act_subject_id = ?', @classroom.ifa_classroom_option.act_subject.id)
    end
    if @classroom.ifa_classroom_option.is_calibrated && !@classroom.ifa_classroom_option.is_user_filtered  && @classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = @classroom.ifa_classroom_option.act_subject.act_assessments.where('is_active AND is_calibrated')
    end
    if @classroom.ifa_classroom_option.is_calibrated && !@classroom.ifa_classroom_option.is_user_filtered  && !@classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = ActAssessment.active.calibrated
    end
    if !@classroom.ifa_classroom_option.is_calibrated && !@classroom.ifa_classroom_option.is_user_filtered  && @classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = @classroom.ifa_classroom_option.act_subject.act_assessments.active
    end
    if !@classroom.ifa_classroom_option.is_calibrated && @classroom.ifa_classroom_option.is_user_filtered  && !@classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = @current_user.act_assessments.active
    end
    if !@classroom.ifa_classroom_option.is_calibrated && !@classroom.ifa_classroom_option.is_user_filtered  && !@classroom.ifa_classroom_option.act_subject_id
      @assessment_pool = ActAssessment.active
    end
    if @classroom.ifa_classroom_option.max_score_filter && @classroom.ifa_classroom_option.act_master_id
      @assessment_pool = @assessment_pool.select{|ass| ass.act_assessment_score_ranges.for_standard(@classroom.ifa_classroom_option.act_master).first.upper_score == @classroom.ifa_classroom_option.max_score_filter.to_i} rescue []
    end
  end
    @assessment_pool.sort!{|a,b| b.updated_at <=> a.updated_at}
 end
   
   
  def find_fav_group_resources
    if @group == 'VIDEO'
      @resource_list = @current_user.favorite_resources.select{|r| (r.content_object_type.content_object_type_group.name == "VIDEO") || (r.content_object_type.content_object_type_group.name == "EMBED CODE") } rescue []
    else
      @resource_list = @current_user.favorite_resources.select{|r| r.content_object_type.content_object_type_group.name == @group } rescue []
    end
 end
  
  
  def update_choices 
    params[:act_choices][:id].each_with_index do |id, i|
      answer = params[:act_choices][:choice][i]
      answer_yes = false
     if params[:act_choices][:correct]
       if params[:act_choices][:correct].include?(i.to_s)
          answer_yes = true
        else
         answer_yes = false
       end
     end
     begin
        if id.blank?
          @choice = @question.act_choices.new
          unless answer.blank? || answer.nil?
            @choice.choice = answer
            @choice.is_correct = answer_yes
            @choice.position = i
            @choice.save
          end
        else
          existing_choice = ActChoice.find(id)
          existing_choice.choice = answer
          existing_choice.is_correct = answer_yes
          existing_choice.update_attributes params[:act_choice]
        end
      rescue ActiveRecord::StatementInvalid => e
        flash[:error] = 'some error happen'
      end
    end    
  end

 #
# Adjust Assessment ranges If Necessary
  def adjust_assessment_ranges
      @question.act_assessments.each do |ass|
        ass.set_min_and_max
   end
  end

  def log_ifa_question(submission, question)
     existing_question = submission.ifa_question_logs.for_question(question).first rescue nil
        unless existing_question
          question_log = IfaQuestionLog.new
          question_log.act_question_id = question.id
          question_log.act_assessment_id = submission.act_assessment_id
          question_log.act_submission_id = submission.id
          question_log.user_id = submission.user_id
          question_log.organization_id = submission.organization_id
          question_log.classroom_id = submission.classroom_id
          question_log.teacher_id = submission.teacher_id
          question_log.act_subject_id = submission.act_subject_id
          question_log.date_taken = submission.created_at
          question_log.period_end = question_log.date_taken.at_end_of_month
          question_log.is_calibrated = question.is_calibrated
          question_log.grade_level = submission.user.current_grade_level
          question_log.csap = submission.user.student_subject_demographics.for_subject(submission.act_subject).first.latest_csap rescue nil
          question_log.earned_points = submission.act_answers.for_question(question).collect{|a|a.points}.sum rescue 0.0
          question_log.choices =  submission.act_answers.for_question(question).selected.size  rescue 0
          question_log.save

### update Question Performance
        
        submission.organization.ifa_org_option.act_masters.each do |mstr|
          student_latest_dashboard = submission.user.ifa_dashboards.for_subject(submission.act_subject).last rescue nil
          student_latest_scores = student_latest_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first rescue nil
          student_range = ActScoreRange.for_standard(mstr).for_subject_sms(submission.act_subject, student_latest_scores.sms_finalized).first rescue nil
          question_range_student = question.ifa_question_performances.for_range(student_range).first rescue nil
          q_earned_points = submission.act_answers.for_question(question).collect{|a|a.points}.sum rescue 0.0
          q_answers = submission.act_answers.for_question(question).selected.size  rescue 0
          
          if student_range
            if question_range_student 
              question_range_student.students += 1
              question_range_student.answers += q_answers
              question_range_student.points += q_earned_points
              #question_range_student.update_attributes(params[:ifa_question_performance])
              question_range_student.save
            else
              question_range_student = IfaQuestionPerformance.new
              question_range_student.act_score_range_id = student_range.id
              question_range_student.students = 1
              question_range_student.points = q_earned_points
              question_range_student.answers = q_answers 
              question_range_student.calibrated_students = 0
              question_range_student.calibrated_student_answers = 0
              question_range_student.calibrated_student_points = 0.0
              question_range_student.baseline_students = 0
              question_range_student.baseline_answers = 0
              question_range_student.baseline_points = 0.0
              question.ifa_question_performances << question_range_student
            end
          end   # end condition if student has existing sms score
          student_calibrated_range = ActScoreRange.for_standard(mstr).for_subject_sms(submission.act_subject, student_latest_scores.sms_calibrated).first rescue nil
          question_range_cal_student = question.ifa_question_performances.for_range(student_calibrated_range).first rescue nil
          if student_calibrated_range
            if question_range_cal_student
              question_range_cal_student.calibrated_students += 1
              question_range_cal_student.calibrated_student_answers += q_answers
              question_range_cal_student.calibrated_student_points += q_earned_points
              #question_range_cal_student.update_attributes(params[:ifa_question_performance])
              question_range_cal_student.save
            else
              question_range_cal_student = IfaQuestionPerformance.new
              question_range_cal_student.act_score_range_id = student_calibrated_range.id
              question_range_cal_student.students = 0
              question_range_cal_student.points = 0.0
              question_range_cal_student.answers = 0
              question_range_cal_student.calibrated_students = 1
              question_range_cal_student.calibrated_student_answers = q_answers  
              question_range_cal_student.calibrated_student_points = q_earned_points
              question_range_cal_student.baseline_students = 0
              question_range_cal_student.baseline_points = 0.0
              question_range_cal_student.baseline_answers = 0
              question.ifa_question_performances << question_range_cal_student
            end 
          end   # end condition if student has existing calibrated sms score
          student_baseline_score = submission.user.ifa_user_baseline_scores.for_subject(submission.act_subject).for_standard(mstr).first.score rescue nil
          student_baseline_range = ActScoreRange.for_standard(mstr).for_subject_sms(submission.act_subject, student_baseline_score).first rescue nil
          question_range_base_student = question.ifa_question_performances.for_range(student_baseline_range).first rescue nil
          if student_baseline_range
            if question_range_base_student
              question_range_base_student.baseline_students += 1
              question_range_base_student.baseline_answers += q_answers
              question_range_base_student.baseline_points += q_earned_points
              #question_range_base_student.update_attributes(params[:ifa_question_performance])
              question_range_base_student.save
            else
              question_range_base_student = IfaQuestionPerformance.new
              question_range_base_student.act_score_range_id = student_baseline_range.id
              question_range_base_student.students = 0
              question_range_base_student.points = 0.0
              question_range_base_student.answers = 0
              question_range_base_student.calibrated_students = 0
              question_range_base_student.calibrated_student_answers = 0  
              question_range_base_student.calibrated_student_points = 0.0
              question_range_base_student.baseline_students = 1
              question_range_base_student.baseline_answers = q_answers  
              question_range_base_student.baseline_points = q_earned_points
              question.ifa_question_performances << question_range_base_student
            end 
          end   # end condition if student has existing baseline score          
        
         end  # End Master Loop for Question Performance
        end
  end

 
  def initialize_parameters 
    @master_standards = ActMaster.all
    @standards = ActStandard.all.collect{|s|[s.standard]}.uniq.sort

    @admin = @current_user.ifa_admin_for_org?(@current_organization)

    if @current_user
      @current_standard = @current_user.standard_view
    else
      @current_standard = ActMaster.default_std
    end
    @options = @current_provider.ifa_org_option rescue nil

    unless @current_user.ifa_user_option
        user_option = IfaUserOption.new
        user_option.is_calibrated = false
        user_option.is_user_filtered = true
        user_option.is_org_filtered = false
        user_option.is_classroom_filtered = false
        user_option.is_colleague_filtered = false
        user_option.is_student_filtered = false
        user_option.beginning_period = @options.begin_school_year
        user_option.act_master_id = ActMaster.default_std.id
        @current_user.ifa_user_option = user_option
    end

    if params[:classroom_id]
      @classroom =Classroom.find_by_public_id(params[:classroom_id])  rescue nil
    end
    if params[:subject_id]
      @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
    end
    if params[:topic_id]
      @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    end
    if params[:question_id]
      @question = ActQuestion.find_by_public_id(params[:question_id])rescue nil
    end
     if params[:assessment_id]
      @assessment = ActAssessment.find_by_public_id(params[:assessment_id])rescue nil
    end 
    if params[:benchmark_id]
      @benchmark = ActBench.find_by_public_id(params[:benchmark_id])rescue nil
    end
    if params[:reading_id]
       @reading = ActRelReading.find_by_public_id(params[:reading_id])rescue nil 
    end
    if params[:submission_id]
       @submission = ActSubmission.find_by_public_id(params[:submission_id])rescue nil 
    end 
   # if params[:app_id]
    #  @app = CoopApp.find_by_id(params[:app_id]) rescue nil
   # end
  end

   def prepare_summary_dashboard

     @subjects = ActSubject.all_subjects
     @total_assessments = []
     @total_answers = []
     @total_points = []
     @total_proficiency = []
     @total_duration = []
     @total_efficiency = []
     @current_assessments = []
     @current_answers = []
     @current_points = []
     @current_proficiency = []
     @current_duration = []
     @current_efficiency = []
     @current_mastery = []
     @current_period = []
     @low_bound = []
     @high_bound =[]
     calibration_filter = @current_user.calibrated_only
     @subjects.each_with_index do |subj, idx|
       @assessments_column_header = calibration_filter ? "Calibrated<br/>Assessments" : "Finalized<br/>Assessments"
       @answers_column_header = calibration_filter ? "Calibrated<br/>Answers" : "Finalized<br/>Answers"
  #     dashboards = IfaDashboard.find(:all, :conditions => ["act_subject_id = ? && ifa_dashboardable_id = ? && ifa_dashboardable_type = ?", subj.id, @current_organization.id, "Organization"],:order=> "period_end ASC") rescue nil
       dashboards = @current_organization.ifa_dashboards.for_subject(subj).where('ifa_dashboardable_type = ?', 'Organization').sort_by{|d| d.period_end}
       unless dashboards.empty?
         @total_assessments[idx] = calibration_filter ? dashboards.collect{|d| d.calibrated_assessments}.sum : dashboards.collect{|d| d.finalized_assessments}.sum rescue 0
         @total_answers[idx] = calibration_filter ? dashboards.collect{|d| d.calibrated_answers}.sum : dashboards.collect{|d| d.finalized_answers}.sum rescue 0
         @total_points[idx] = calibration_filter ? dashboards.collect{|d| d.cal_points}.sum : dashboards.collect{|d| d.fin_points}.sum rescue 0.0
         @total_duration[idx] = calibration_filter ? dashboards.collect{|d| d.calibrated_duration}.sum : dashboards.collect{|d| d.finalized_duration}.sum rescue 0

         duration_points = calibration_filter ? dashboards.collect{|d| d.cal_submission_points}.sum : @total_points[idx] rescue 0
         @total_efficiency[idx] = duration_points == 0 ? "-" : (@total_duration[idx].to_f/duration_points.to_f).round
         @total_proficiency[idx] = @total_answers[idx] == 0 ? "" : (100*@total_points[idx].to_f/@total_answers[idx].to_f).round

         @current_dashboard = dashboards.last rescue nil
         if @current_dashboard
           @current_assessments[idx] = calibration_filter ? @current_dashboard.calibrated_assessments : @current_dashboard.finalized_assessments rescue 0
           @current_answers[idx] = calibration_filter ? @current_dashboard.calibrated_answers : @current_dashboard.finalized_answers rescue 0
           @current_points[idx] = calibration_filter ? @current_dashboard.cal_points : @current_dashboard.fin_points rescue 0.0
           @current_duration[idx] = calibration_filter ? @current_dashboard.calibrated_duration : @current_dashboard.finalized_duration rescue 0
           duration_points = calibration_filter ? @current_dashboard.cal_submission_points : @current_points[idx] rescue 0.0
           @current_efficiency[idx] = duration_points == 0 ? "-" : (@current_duration[idx].to_f/duration_points.to_f).round
           @current_proficiency[idx] = @current_answers[idx] == 0 ? "" : (100*@current_points[idx].to_f/@current_answers[idx].to_f).round

           mastery_scores = @current_dashboard.ifa_dashboard_sms_scores.for_standard(@current_standard).first rescue nil
           if mastery_scores
             @current_mastery[idx] = calibration_filter ? mastery_scores.sms_calibrated : mastery_scores.sms_finalized
             @low_bound[idx] = mastery_scores.score_range_min
             @high_bound[idx] = mastery_scores.score_range_max

           else
             @current_mastery[idx] = ''
             @low_bound[idx] = ''
             @high_bound[idx] = ''
           end
           @current_period[idx] = @current_dashboard.period_end.strftime("%b, %Y")
         end
       end
     end
   end

   def prepare_summary_data
     @subjects = ActSubject.all_subjects
     @total_submissions = []
     calibration_filter = @current_user.calibrated_only
     @subjects.each_with_index do |subj, idx|
       @total_submissions[idx] = @current_organization.act_submissions.for_subject(subj).size
     end
   end

  def student_growth_plans
    @prep_students={}
    ActSubject.plannable.each do |subj|
      @prep_students[subj] = @current_organization.precision_prep_students(subj)
    end
  end

  def question_creators_strands
    @question_creators = ActQuestion.creators
    @current_strands = ActStandard.active_strands(:standard=>@current_standard)
  end

  def assessment_creators
    @assessment_creators = ActAssessment.creators
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

  def prepare_single_ifa_dashboard(dashboard)

  if dashboard
    then 
    if dashboard.ifa_dashboardable_type == "User" 
      @dashboard_name = dashboard.ifa_dashboardable.full_name
    elsif dashboard.ifa_dashboardable_type == "Classroom"
      @dashboard_name = dashboard.ifa_dashboardable.course_name
    elsif dashboard.ifa_dashboardable_type == "Organization"
      @dashboard_name = dashboard.ifa_dashboardable.medium_name
    else
      @dashboard_name = ""
    end      
    @end_period = dashboard.period_ending
    calibration_filter = @current_user.calibrated_only
    @total_taken = dashboard.assessments_taken
    scores = dashboard.ifa_dashboard_sms_scores.for_standard(@current_standard).first rescue nil
    @total_assessments = calibration_filter ? dashboard.calibrated_assessments : dashboard.finalized_assessments rescue 0
    @total_answers = calibration_filter ? dashboard.calibrated_answers : dashboard.finalized_answers rescue 0    
    @total_points = calibration_filter ? dashboard.cal_points : dashboard.fin_points rescue 0.0   
    @total_duration = calibration_filter ? dashboard.calibrated_duration : dashboard.finalized_duration rescue 0   
    @total_proficiency =  @total_answers == 0 ? 0 : (100*@total_points.to_f/@total_answers.to_f).round
    duration_points = calibration_filter ? dashboard.cal_submission_points : @total_points
    @total_efficiency =  duration_points == 0 ? 0 : (@total_duration.to_f/duration_points.to_f).round

    @current_sms_f = scores.sms_finalized rescue ""
    @current_sms_f = (@current_user.sat_view? && @current_sms_f != "") ? ActScoreRange.sat_score(@current_standard, @current_subject, @current_sms_f) : @current_sms_f
    @current_sms_c = scores.sms_calibrated rescue ""
    @current_sms_c = (@current_user.sat_view? && @current_sms_c != "") ? ActScoreRange.sat_score(@current_standard, @current_subject, @current_sms_c) : @current_sms_c
    @baseline_score = scores.baseline_score rescue nil
    @min_range = scores.score_range_min rescue 0
    @max_range = scores.score_range_max rescue 0

    @full_range_list = ActScoreRange.no_na.for_standard_and_subject(@current_standard, @current_subject) rescue []
    @range_list = @full_range_list.select{|r| @min_range <= r.upper_score && @max_range >= r.lower_score} rescue []
  
    @range_answers = []
    @range_points = []  
    @range_pct = []
    @range_hover_text = []
    @hover_text = true
    @strand_list = ActStandard.for_standard_and_subject(@current_standard, @current_subject) rescue []
    @range_list.each_with_index do |r,rdx|
      @range_answers[rdx] = []
      @range_points[rdx] = []
      @range_hover_text[rdx] = []    
      @strand_list.each_with_index do |s,sdx|
        sdx_answers = 0
        sdx_points = 0
        sdx_hover_text = ""
        unless dashboard.nil?

         cell_stats = dashboard.ifa_dashboard_cells.for_range_and_strand(r, s).first rescue nil
         if cell_stats
          sdx_answers += calibration_filter ? cell_stats.calibrated_answers : cell_stats.finalized_answers
          sdx_points += calibration_filter ? cell_stats.cal_points : cell_stats.fin_points     
          unless dashboard.ifa_dashboardable_type == "User" || cell_stats.nil?
            sdx_hover_text += calibration_filter ? (cell_stats.calibrated_hover.nil? ? '' : cell_stats.calibrated_hover) : (cell_stats.finalized_hover.nil? ? '' : cell_stats.finalized_hover)
            sdx_hover_text += "<br/>"
          end
          end  # Cell Stats Present
        end  
# Load stats for cell 
    @range_answers[rdx] << sdx_answers
    @range_points[rdx] << sdx_points
    @range_hover_text[rdx] << sdx_hover_text
    end   # End Strand Column   
  
    end # End Range Row
  
  else # no dashboard
    @dashboard_name = @current_organization.medium_name
    @end_period = Date.today
    @total_assessments =  0
    @total_answers =  0    
    @total_points =  0   
    @total_duration =  0   
    @total_proficiency =  0
    @total_efficiency =  0
    @min_range =  0
    @max_range =  0
    @full_range_list =  []
    @range_list =  []
    @range_answers = []
    @range_points = []  
    @range_pct = []
    @strand_list = ActStandard.for_standard_and_subject(@current_standard, @current_subject) rescue []
  end
  end

  def prepare_single_dashboard_details
    @entity_submission_list = []
    window_begin = @entity_dashboard.period_beginning
    window_end = @entity_dashboard.period_end
    if @entity_dashboard.ifa_dashboardable_type == "Organization"
      @entity_submission_list = Organization.find_by_id(@entity_dashboard.ifa_dashboardable_id).act_submissions.for_subject(@current_subject).select{|s| s.date_finalized && s.created_at >= window_begin && s.created_at <= window_end}.sort{|a,b| b.created_at <=> a.created_at}  
    end
    if @entity_dashboard.ifa_dashboardable_type == "Classroom"
      @entity_submission_list = Classroom.find_by_id(@entity_dashboard.ifa_dashboardable_id).act_submissions.for_subject(@current_subject).select{|s| s.date_finalized && s.created_at >= window_begin && s.created_at <= window_end}.sort{|a,b| b.created_at <=> a.created_at}  
    end
    if @entity_dashboard.ifa_dashboardable_type == "User"
      @entity_submission_list = User.find_by_id(@entity_dashboard.ifa_dashboardable_id).act_submissions.for_subject(@current_subject).select{|s| s.date_finalized && s.created_at >= window_begin && s.created_at <= window_end}.sort{|a,b| b.created_at <=> a.created_at}  
    end 
    @entity_assessments = @entity_submission_list.collect{|sub| sub.act_assessment}.flatten.uniq.sort{|a,b| b.updated_at <=> a.updated_at} 
   
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

  def manual_ifa_dashboard_update
    
    months_back = params[:periods].to_i rescue 0
    month_begin = Date.today.at_beginning_of_month - months_back.months 
    entity_list = []
    entity_class = params[:entity_class].to_s

#  Comprehensive Updates Requested from Superuser CRUD    
    if params[:requester] == "CRUD"
      if entity_class == "User"
        entity_list = User.all
      end
      if entity_class == "Classroom"
        entity_list = Classroom.all
      end      
      if entity_class == "Organization"
        entity_list = Organization.all
      end
      if params[:update_type] == "Full"
        full_update = true
      end
    end

#  Organizational Updates Requested from IFA Admin Options    
    if params[:requester] == "Admin"
      if entity_class == "User"
        entity_list = @current_organization.users
      end
      if entity_class == "Classroom"
        entity_list = @current_organization.classrooms
      end      
      if entity_class == "Organization"
        entity_list << @current_organization
      end
    end   

#  Classroom Updates Requested from Teacher IFA Review    
    if params[:requester] == "Teacher"
      if entity_class == "User"
        entity_list = @ifa_classroom.participants
      end
      
      if entity_class == "Classroom"
          entity_list <<  @ifa_classroom 
        end
    end 
  
#  User Updates Requested from Student IFA Review    
    if params[:requester] == "Student"    
      entity_class = "User"
        if @current_user
          entity_list <<  @current_user 
        end
    end
    
 
# Cycle Months
    until month_begin > Date.today
    month_end = month_begin.at_end_of_month


#  Cycle Subjects    
    ifa_subjects = ActSubject.all
    ifa_subjects.each do |subj|

 
#  Cycle Entities
      entity_list.each do |entity|
        if entity_class == "User" 
          entity_org_id = entity.home_org_id
          entity_org = entity.home_organization
        elsif entity_class == "Classroom" 
          entity_org_id = entity.organization_id
          entity_org = entity.organization
        else
          entity_org_id = entity.id
          entity_org = entity
        end

        org_options = IfaOrgOption.find_by_organization_id(entity_org_id) rescue nil

        if org_options
          sms_date = month_end > Date.today ? (Date.today - org_options.sms_calc_cycle.days) : (month_end - org_options.sms_calc_cycle.days)          

          submissions = entity.act_submissions.for_subject(subj).select{|s| s.created_at >= month_begin && s.created_at <= month_end} rescue []
          submissions_for_sms_calc = entity.act_submissions.for_subject(subj).select{|s| s.created_at >= sms_date && s.created_at <= month_end} rescue []
          finalized_submissions = submissions.select{|sub| sub.is_final} rescue []
          finalized_submissions_for_sms_calc = submissions_for_sms_calc.select{|sub| sub.is_final} rescue []
          calibrated_submissions = finalized_submissions.select{|sub| sub.act_assessment.is_calibrated} rescue []
          calibrated_submissions_for_sms_calc = finalized_submissions_for_sms_calc.select{|sub| sub.act_assessment.is_calibrated} rescue []
          finalized_answers = finalized_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          finalized_answers_for_sms_calc = finalized_submissions_for_sms_calc.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          cal_submission_answers = calibrated_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_answers = finalized_answers.select{|a| a.act_question.is_calibrated} rescue []
          calibrated_answers_for_sms_calc = finalized_answers_for_sms_calc.select{|a| a.act_question.is_calibrated} rescue []

#          entity_dashboards = IfaDashboard.find(:all, :conditions => ["ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ? AND act_subject_id = ? AND organization_id = ?", entity.id, entity.class.to_s,  month_end, subj.id, entity_org_id]) rescue []
          entity_dashboards = IfaDashboard.where("ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ? AND act_subject_id = ? AND organization_id = ?", entity.id, entity.class.to_s,  month_end, subj.id, entity_org_id) rescue []
           if entity_dashboards.size > 1
            entity_dashboards.each do |db|
              db.destroy
            end
          else
            entity_dashboard = entity_dashboards.first
          end          
          if entity_dashboard && submissions.size.zero?
      #  submissions were deleted, remove dashboard    
            entity_dashboard.destroy
        else
          
         if entity_class == "User"
           subsmissions_not_dashboarded = submissions.select{|s| !s.is_user_dashboarded} rescue []           
         end
         if entity_class == "Classroom"
           subsmissions_not_dashboarded = submissions.select{|s| !s.is_classroom_dashboarded} rescue []           
         end
         if entity_class == "Organization"
           subsmissions_not_dashboarded = submissions.select{|s| !s.is_org_dashboarded} rescue []           
         end

         if subsmissions_not_dashboarded.size > 0 || (entity_dashboard.nil? && submissions.size > 0) || (full_update && submissions.size > 0)
        #  submissions that haven't yet been dashboarded exist or the dashboard has been deleted but there are submissions anyway
        # full update anyway as long as there are submissions
           if entity_dashboard 
      #  remove existing dashboard   
            entity_dashboard.destroy
           end
      # create a new dashboard            
            entity_dashboard = IfaDashboard.new
            entity_dashboard.ifa_dashboardable_id = entity.id
            entity_dashboard.ifa_dashboardable_type = entity.class.to_s
            entity_dashboard.period_end = month_end
            entity_dashboard.organization_id = entity_org_id
            entity_dashboard.act_subject_id = subj.id
            entity_dashboard.assessments_taken = submissions.size rescue 0
            entity_dashboard.finalized_assessments = finalized_submissions.size rescue 0
            entity_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
            entity_dashboard.finalized_answers = finalized_answers.size rescue 0
            entity_dashboard.calibrated_answers = calibrated_answers.size rescue 0
            entity_dashboard.cal_submission_answers = cal_submission_answers.size rescue 0
            entity_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
            entity_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
            entity_dashboard.fin_points = finalized_answers.collect{|a| a.points}.sum rescue 0.0
            entity_dashboard.cal_points = calibrated_answers.collect{|a| a.points}.sum rescue 0.0           
            entity_dashboard.cal_submission_points = cal_submission_answers.collect{|a| a.points}.sum rescue 0
            entity_dashboard.save

#  SMS for each Master Standard for the 
            unless entity_org.ifa_org_option.act_masters.empty?
            entity_org.ifa_org_option.act_masters.each do |mstr|
              master_sms_finalized = 0
              master_sms_calibrated = 0
              assessment_ids = finalized_submissions.collect{|s| s.act_assessment_id}.uniq rescue []
#    collect. act_assessments from submissions won't work
              min_score = 999999
              max_score = 0
              assessment_ids.each do |a|
                ass_score_range = ActAssessmentScoreRange.where("act_assessment_id = ? AND act_master_id =?", a, mstr.id).first rescue nil
                if ass_score_range
                  if ass_score_range.lower_score < min_score then min_score = ass_score_range.lower_score end
                  if ass_score_range.upper_score > max_score then max_score = ass_score_range.upper_score end
                end
              end

              unless finalized_answers_for_sms_calc.empty?
                master_sms_finalized = mstr.sms(finalized_answers_for_sms_calc, subj.id, 0,0, entity_org_id)
              end
              unless calibrated_answers_for_sms_calc.empty?
                master_sms_calibrated = mstr.sms(calibrated_answers_for_sms_calc, subj.id, 0,0, entity_org_id)
              end            
              unless max_score == 0
                dashboard_score = IfaDashboardSmsScore.new
                dashboard_score.sms_finalized = master_sms_finalized
                dashboard_score.sms_calibrated = master_sms_calibrated
                dashboard_score.score_range_min = min_score
                dashboard_score.score_range_max = max_score
                dashboard_score.act_master_id = mstr.id
                entity_dashboard.ifa_dashboard_sms_scores << dashboard_score
              end   # End SMS Update For Mstr 

#  Each Dashboard Cell          
           
              ranges = mstr.act_score_ranges.select{ |r| r.act_subject_id == subj.id} rescue []
              standards = mstr.act_standards.select{ |s| s.act_subject_id == subj.id} rescue []            
              ranges.each do |range|
                unless max_score < range.lower_score || min_score > range.upper_score
                  standards.each do |std|
                    finalized_cell_ans = cell_answers(finalized_answers,std.id, range.id)
                    calibrated_cell_ans = cell_answers(calibrated_answers,std.id, range.id)
                    unless finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                      dashboard_cell = IfaDashboardCell.new
                      dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                      dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
# Generate hover Text

                      if entity_class == "Classroom"
                        dashboard_cell.finalized_hover = target_students(finalized_cell_ans, 75)
                        dashboard_cell.calibrated_hover = target_students(calibrated_cell_ans, 75)
                      end
                      if entity_class == "Organization"
                        dashboard_cell.finalized_hover = target_classrooms(finalized_cell_ans, 75)
                        dashboard_cell.calibrated_hover = target_classrooms(calibrated_cell_ans, 75)   
                      end

                      dashboard_cell.fin_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                      dashboard_cell.cal_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
                      dashboard_cell.act_master_id = mstr.id
                      dashboard_cell.act_score_range_id = range.id
                      dashboard_cell.act_standard_id = std.id              
                      entity_dashboard.ifa_dashboard_cells << dashboard_cell
                    end
                  end  #  End Column Cycle
                end  # Score Range Condition
              end   # End Row Cycle
            end  # End Master Cycle
            end  # No IFA Masters for Org
#
#     Set Submission "Dashboarded" Indicators
            if entity_class == "User"
                subsmissions_not_dashboarded.each do |sub|
                  sub.update_attributes(:is_user_dashboarded => true)
              end
            end
            if entity_class == "Classroom"
              subsmissions_not_dashboarded.each do |sub|
                sub.update_attributes(:is_classroom_dashboarded => true)
              end
            end
            if entity_class == "Organization"
              subsmissions_not_dashboarded.each do |sub|
                sub.update_attributes(:is_org_dashboarded => true)
              end
            end            
            
          end #End Not Dashboarded Submissions Condition 
        end # Removed Dashboard with No Submissions
        end # End IFA Org condition
      end  # End Entity Cycle

    end # End Subject Cycle
    month_begin += 1.month
  end   # End Month Cycle
 end  # End of Action

  def auto_ifa_dashboard_update(submission, entity)
    if entity.class.to_s == "User" 
      if submission.is_user_dashboarded
        already_dashboarded = true
      else  
        already_dashboarded = false
        entity_dashboard = submission.user.ifa_dashboards.for_subject(submission.act_subject).for_period(submission.created_at.to_date.at_end_of_month).first
        dashboardable_id = submission.user_id
        submission.update_attributes(:is_user_dashboarded => true)
      end
    elsif entity.class.to_s == "Classroom"
      if submission.is_classroom_dashboarded
        already_dashboarded = true
      else  
        already_dashboarded = false        
        entity_dashboard = submission.classroom.ifa_dashboards.for_subject(submission.act_subject).for_period(submission.created_at.to_date.at_end_of_month).first
        dashboardable_id = submission.classroom_id
        submission.update_attributes(:is_classroom_dashboarded => true)
      end
    elsif entity.class.to_s == "Organization"
      if submission.is_org_dashboarded
        already_dashboarded = true
      else  
        already_dashboarded = false
        entity_dashboard = submission.organization.ifa_dashboards.for_subject(submission.act_subject).for_period(submission.created_at.to_date.at_end_of_month).first
        dashboardable_id = submission.organization_id
        submission.update_attributes(:is_org_dashboarded => true)
      end
    end  
    unless already_dashboarded
      unless entity_dashboard
        entity_dashboard = IfaDashboard.new
              entity_dashboard.ifa_dashboardable_id = dashboardable_id
              entity_dashboard.ifa_dashboardable_type = entity.class.to_s
              entity_dashboard.period_end = submission.created_at.to_date.at_end_of_month
              entity_dashboard.organization_id = submission.classroom.organization_id
              entity_dashboard.act_subject_id = submission.act_subject_id
              entity_dashboard.assessments_taken = 1
              entity_dashboard.finalized_assessments = 1
              entity_dashboard.calibrated_assessments = submission.act_assessment.is_calibrated ? 1: 0
              entity_dashboard.finalized_answers = submission.act_answers.selected.size rescue 0
              entity_dashboard.calibrated_answers = submission.act_answers.calibrated.selected.size rescue 0
              entity_dashboard.cal_submission_answers = submission.act_assessment.is_calibrated ? submission.act_answers.calibrated.selected.size : 0
              entity_dashboard.finalized_duration = submission.duration
              entity_dashboard.calibrated_duration = submission.act_assessment.is_calibrated ?  submission.duration : 0
              entity_dashboard.fin_points = submission.act_answers.collect{|a|a.points}.sum rescue 0.0
              entity_dashboard.cal_points = submission.act_answers.calibrated.collect{|a|a.points}.sum rescue 0.0
              entity_dashboard.cal_submission_points = submission.act_assessment.is_calibrated ? submission.act_answers.calibrated.collect{|a|a.points}.sum : 0
         entity_dashboard.save
      else
            entity_dashboard.assessments_taken += 1
            entity_dashboard.finalized_assessments += 1
            entity_dashboard.finalized_answers += submission.act_answers.selected.size
            entity_dashboard.calibrated_answers += submission.act_answers.calibrated.selected.size
            entity_dashboard.finalized_duration += submission.duration
            entity_dashboard.fin_points += submission.act_answers.collect{|a|a.points}.sum
            entity_dashboard.cal_points += submission.act_answers.calibrated.collect{|a|a.points}.sum
            if submission.act_assessment.is_calibrated
              entity_dashboard.calibrated_assessments += 1
              entity_dashboard.calibrated_duration += submission.duration
              entity_dashboard.cal_submission_points += submission.act_answers.calibrated.collect{|a|a.points}.sum
              entity_dashboard.cal_submission_answers += submission.act_answers.calibrated.selected.size
            end
         entity_dashboard.update_attributes(params[:ifa_dashboard])
      end

    ifa_org_option = Organization.find_by_id(entity_dashboard.organization_id).ifa_org_option rescue nil
    if ifa_org_option
      ifa_org_option.act_masters.each do |mstr|
      submission.ifa_question_logs.each do |log|
          q_range = log.act_question.act_score_ranges.for_standard(mstr).first rescue nil
          q_strand = log.act_question.act_standards.for_standard(mstr).first rescue nil
          if q_range && q_strand
            dashboard_cell = entity_dashboard.ifa_dashboard_cells.with_range_id(q_range.id).with_strand_id(q_strand.id).first 
            unless dashboard_cell
              dashboard_cell = IfaDashboardCell.new
              dashboard_cell.act_master_id = mstr.id
              dashboard_cell.act_score_range_id = q_range.id
              dashboard_cell.act_standard_id = q_strand.id
              dashboard_cell.finalized_answers = log.choices
              dashboard_cell.calibrated_answers = log.is_calibrated ? log.choices : 0                  
              dashboard_cell.fin_points = log.earned_points
              dashboard_cell.cal_points = log.is_calibrated ? log.earned_points : 0.0
#              dashboard_cell.finalized_hover = target_hovers(entity, submission.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, submission.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, true)
              entity_dashboard.ifa_dashboard_cells << dashboard_cell
            else
              dashboard_cell.finalized_answers += log.choices
              dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0                  
              dashboard_cell.fin_points += log.earned_points
              dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0 
#              dashboard_cell.finalized_hover = target_hovers(entity, submission.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, submission.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, true)
              dashboard_cell.update_attributes(params[:ifa_dashboard_cell]) 
            end
          end
        end    # End Log Loop 

        dashboard_sms = entity_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first
        up_to_date = Date.today
        since_date = (up_to_date - submission.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
        h_threshold = submission.organization.ifa_org_option.sms_h_threshold rescue 0.75
        unless dashboard_sms
          dashboard_sms = IfaDashboardSmsScore.new
          dashboard_sms.act_master_id = mstr.id
          dashboard_sms.score_range_min = submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
          dashboard_sms.score_range_max = submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
          dashboard_sms.sms_finalized = mstr.sms_for_period(entity, submission.act_subject, entity_dashboard.period_ending, h_threshold, false)
          dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, submission.act_subject, entity_dashboard.period_ending, h_threshold, true)
          dashboard_sms.baseline_score = mstr.base_score(entity, submission.act_subject)
          entity_dashboard.ifa_dashboard_sms_scores << dashboard_sms            
        else
          new_min = submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
          if (new_min < dashboard_sms.score_range_min && new_min != 0) then dashboard_sms.score_range_min = new_min end 
            new_max =  submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
          if (new_max > dashboard_sms.score_range_max && new_max != 0) then dashboard_sms.score_range_max =  new_max end 
            dashboard_sms.sms_finalized = mstr.sms_for_period(entity, submission.act_subject, entity_dashboard.period_ending, h_threshold, false)
            dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, submission.act_subject, entity_dashboard.period_ending, h_threshold, true)
            dashboard_sms.baseline_score = mstr.base_score(entity, submission.act_subject)
            dashboard_sms.update_attributes(params[:ifa_dashboard_sms_score]) 
        end 
      end  # end Master Loop
    end
  end  # no IFA ORG Options
  end # Already Dashboarded Condition
 
 def target_hovers(entity, subject, range, strand, since_date,threshold, calibrate_only)
    target_list = ""
    target_count = 0
    question_log_list = calibrate_only ? entity.ifa_question_logs.for_subject(subject).calibrated.since(since_date) :  entity.ifa_question_logs.for_subject(subject).since(since_date)  
    cell_questions = question_log_list.select{|ql| ql.act_question.act_score_ranges.include?(range) && ql.act_question.act_standards.include?(strand)}
    if entity.class.to_s == "Classroom"
      question_users = cell_questions.collect{|ql| ql.user_id}.uniq
      question_users.each do |uid|
        answers = question_log_list.select{|ql| ql.user_id == uid}.sum{|q| q.choices}
        points = question_log_list.select{|ql| ql.user_id == uid}.sum{|q| q.earned_points}
        pct = answers == 0 ? 100.0 : points/answers
        if (100*pct < threshold)
          student_name = User.find_by_id(uid).last_name rescue nil
          if student_name
            target_count += 1
            target_list += target_count == 1 ? student_name : ("," + student_name)
          end
        end
      end
      student_label = target_count == 1 ? " Student " : " Students "
      hover_string = "<strong/>" + target_count.to_s + student_label + "Below " + threshold.to_s + "%</strong><br/>" + target_list
    else
      question_clsrms = cell_questions.collect{|ql| ql.classroom_id}.uniq
      question_clsrms.each do |cid|
        answers = question_log_list.select{|ql| ql.classroom_id == cid}.sum{|q| q.choices}
        points = question_log_list.select{|ql| ql.classroom_id == cid}.sum{|q| q.earned_points}
        pct = answers == 0 ? 0 : (100*points/answers).round.to_i
        classroom = Classroom.find_by_id(cid) rescue nil
        if classroom
          classroom_name = classroom.course_name
          classroom_leaders = classroom.teacher_list
          classroom_string = pct > threshold ? (pct.to_s + "% " + classroom_name + ": " + classroom_leaders + "<br/>") : ("<strong>" + pct.to_s + "% " + classroom_name + ": " + classroom_leaders + "</strong><br/>")
          target_list += classroom_string
        end
       end
      hover_string = target_list
    end
    hover_string 
  end

  def update_cells_in_user_dashboard(db)

      if db.organization && db.act_subject && db.ifa_dashboardable && @current_standard
        db.ifa_dashboard_cells.for_standard(@current_standard).destroy_all
#        sms_date = db.period_end > Date.today ? (Date.today - db.organization.ifa_org_option.sms_calc_cycle.days) : (db.period_end - db.organization.ifa_org_option.sms_calc_cycle.days)          

        finalized_submissions = db.ifa_dashboardable.act_submissions.for_subject(db.act_subject).submission_period(db.period_end.beginning_of_month, db.period_end).final
 #       submissions_for_sms_calc = db.ifa_dashboardable.act_submissions.for_subject(db.act_subject).select{|s| s.created_at >= sms_date && s.created_at <= db.period_end} 
 #       finalized_submissions_for_sms_calc = submissions_for_sms_calc.select{|sub| sub.is_final}
 #       calibrated_submissions = finalized_submissions.select{|sub| sub.act_assessment.is_calibrated}
 #       calibrated_submissions_for_sms_calc = finalized_submissions_for_sms_calc.select{|sub| sub.act_assessment.is_calibrated} 
        finalized_answers = finalized_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} 
 #       finalized_answers_for_sms_calc = finalized_submissions_for_sms_calc.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} 
 #       cal_submission_answers = calibrated_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} 
        calibrated_answers = finalized_answers.select{|a| a.act_question.is_calibrated} 
 #       calibrated_answers_for_sms_calc = finalized_answers_for_sms_calc.select{|a| a.act_question.is_calibrated}

        assessment_ids = finalized_submissions.collect{|s| s.act_assessment_id}.uniq
#    collect. act_assessments from submissions won't work
        @min_score = 999999
        @max_score = 0
        assessment_ids.each do |a|
          ass_score_range = a.act_assessment_score_ranges.for_standard(@current_standard).first
          if ass_score_range
            if ass_score_range.lower_score < @min_score then @min_score = ass_score_range.lower_score end
            if ass_score_range.upper_score > @max_score then @max_score = ass_score_range.upper_score end
          end
        end

#  Each Dashboard Cell          
                     
         @current_standard.act_score_ranges.for_subject(db.act_subject).each do |range|
          unless @max_score < range.lower_score || @min_score > range.upper_score
            @current_standard.act_standards.for_subject(db.act_subject).each do |std|
              finalized_cell_ans = cell_answers(finalized_answers,std.id, range.id)
              calibrated_cell_ans = cell_answers(calibrated_answers,std.id, range.id)
              unless finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                dashboard_cell = IfaDashboardCell.new
                dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
# Generate hover Text

                if db.ifa_dashboardable_type == "Classroom"
                  dashboard_cell.finalized_hover = target_students(finalized_cell_ans, 75)
                  dashboard_cell.calibrated_hover = target_students(calibrated_cell_ans, 75)
                end
                if db.ifa_dashboardable_type == "Organization"
                  dashboard_cell.finalized_hover = target_classrooms(finalized_cell_ans, 75)
                  dashboard_cell.calibrated_hover = target_classrooms(calibrated_cell_ans, 75)   
                end

                dashboard_cell.fin_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                dashboard_cell.cal_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
                dashboard_cell.act_master_id = @current_standard.id
                dashboard_cell.act_score_range_id = range.id
                dashboard_cell.act_standard_id = std.id              
                db.ifa_dashboard_cells << dashboard_cell
              end
            end  #  End Column Cycle
          end  # Score Range Condition
        end 
    end
  end

  def update_sms_in_user_dashboard(db)

      if db.organization && db.act_subject && db.ifa_dashboardable && @current_standard
        db.ifa_dashboard_sms_scores.for_standard(@current_standard).destroy_all
        sms_date = db.period_end > Date.today ? (Date.today - db.organization.ifa_org_option.sms_calc_cycle.days) : (db.period_end - db.organization.ifa_org_option.sms_calc_cycle.days)          

        submissions = db.ifa_dashboardable.act_submissions.for_subject(db.act_subject).submission_period(db.period_end.beginning_of_month, db.period_end)
        submissions_for_sms_calc = db.ifa_dashboardable.act_submissions.for_subject(db.act_subject).select{|s| s.created_at >= sms_date && s.created_at <= db.period_end} 
        finalized_submissions = submissions.select{|sub| sub.is_final}
        finalized_submissions_for_sms_calc = submissions_for_sms_calc.select{|sub| sub.is_final}
        calibrated_submissions = finalized_submissions.select{|sub| sub.act_assessment.is_calibrated}
        calibrated_submissions_for_sms_calc = finalized_submissions_for_sms_calc.select{|sub| sub.act_assessment.is_calibrated} 
        finalized_answers = finalized_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} 
        finalized_answers_for_sms_calc = finalized_submissions_for_sms_calc.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} 
        cal_submission_answers = calibrated_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} 
        calibrated_answers = finalized_answers.select{|a| a.act_question.is_calibrated} 
        calibrated_answers_for_sms_calc = finalized_answers_for_sms_calc.select{|a| a.act_question.is_calibrated}

#  SMS for Current Standard  
        master_sms_finalized = 0
        master_sms_calibrated = 0
        assessment_ids = finalized_submissions.collect{|s| s.act_assessment_id}.uniq
#    collect. act_assessments from submissions won't work
        @min_score = 999999
        @max_score = 0
        assessment_ids.each do |a|
          ass_score_range = a.act_assessment_score_ranges.for_standard(@current_standard).first
          if ass_score_range
            if ass_score_range.lower_score < @min_score then @min_score = ass_score_range.lower_score end
            if ass_score_range.upper_score > @max_score then @max_score = ass_score_range.upper_score end
          end
        end
        unless finalized_answers_for_sms_calc.empty?
          master_sms_finalized = @current_standard.sms(finalized_answers_for_sms_calc, db.act_subject.id, 0,0, db.organization_id)
        end
        unless calibrated_answers_for_sms_calc.empty?
          master_sms_calibrated = @current_standard.sms(calibrated_answers_for_sms_calc, db.act_subject.id, 0,0, db.organization_id)
        end            
        unless @max_score == 0
          dashboard_score = IfaDashboardSmsScore.new
          dashboard_score.sms_finalized = master_sms_finalized
          dashboard_score.sms_calibrated = master_sms_calibrated
          dashboard_score.score_range_min = @min_score
          dashboard_score.score_range_max = @max_score
          dashboard_score.act_master_id = @current_standard.id
          db.ifa_dashboard_sms_scores << dashboard_score
        end 
      @temp_count = submissions.size
    end
  end
   def org_analysys_instance_variables
     @dashboard_name = @current_organization.medium_name
  #   @org_family = (@current_provider == @current_organization) ? @current_organization.provided_app_orgs(@current_application, true)
 #    : @current_organization.active_siblings_same_type
     @app_orgs = @current_provider.provided_app_orgs(@current_application, true)
     @current_org_dashboards = @current_organization.ifa_dashboards.for_subject(@current_subject).reverse
   #  @current_org_dashboards =IfaDashboard.org_subject_after_date('Organization', @current_organization, @current_subject, @current_provider.ifa_org_option.begin_school_year).reverse
     @classroom_list =(@current_provider == @current_organization) ? @current_organization.precision_prep_provider_classrooms(@current_subject)
         : @current_organization.classrooms.precision_prep_subject(@current_subject).sort{|a,b| a.course_name <=> b.course_name}
     @student_list = (@current_provider == @current_organization) ? @current_organization.precision_prep_provider_students
     : @current_organization.classrooms.precision_prep_students.sort{|a,b| a.last_name <=> b.last_name}
     @prep_classrooms = @current_organization.classrooms.active.precision_prep
   end

  def user_ifa_plans
    @user_plans = {}
    ActSubject.plannable.each do |subject|
      unless @current_user.ifa_plan_subject(subject).nil?
        @user_plans[subject] = @current_user.ifa_plan_subject(subject)
      end
    end
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

  def get_subject
    if params[:subject_id]
      @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
    end
  end

  def get_standard
    if params[:standard_id]
      @current_standard = ActMaster.find_by_id(params[:standard_id]) rescue nil
    end
  end

 end
