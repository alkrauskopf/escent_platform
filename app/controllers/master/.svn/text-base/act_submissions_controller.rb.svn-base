class Master::ActSubmissionsController < Master::ApplicationController

  layout "master"
  
  before_filter :find_submission, :only => [:edit, :show, :delete]
  
  def index
    @submissions = ActSubmission.find :all
  end
 
  def completed_crud_conversion
  end
  
  def new
    @submission = ActSubmission.new
    if request.post?
      @submission = ActSubmission.new(params[:submission])
      if @submission.save
        flash[:notice] = "Successfully created submission #{@submission.id}."
        redirect_to :action => :index
      else
        flash[:error] = @submission.errors.full_messages.to_sentence
      end
    end
  end
  
  def edit
    if request.post?
      if @submission.update_attributes(params[:submission])
          flash[:notice] = "Successfully updated submission #{@submission.id}."
          redirect_to :action => :index
      else
        flash[:error] = @submission.errors.full_messages.to_sentence
      end
    end
  end
  
  def show
  end
  
  def delete
    if request.post?
      @submission.destroy
      flash[:notice] = "Successfully removed submission #{@submission.id}."
      redirect_to :action => :index
    end
  end

  def update_sms_in_org_dashboards
    all_dashboards = IfaDashboard.find(:all, :conditions => ["ifa_dashboardable_type = ?", "Organization"]) 
    all_dashboards.each do |db|
       org = db.organization
       subject = ActSubject.find_by_id(db.act_subject_id)
       if org && (db.period_end > Date.today - 2.months)
         entity = Organization.find_by_id(db.ifa_dashboardable_id) rescue nil
         if entity
         db.ifa_dashboard_sms_scores.each do |scores|
              fin_sms = scores.act_master.sms_for_period(entity,  subject, db.period_end, org.ifa_org_option.sms_h_threshold, false)
              cal_sms = scores.act_master.sms_for_period(entity,  subject, db.period_end, org.ifa_org_option.sms_h_threshold, true)
              scores.update_attributes(:sms_finalized => fin_sms, :sms_calibrated => cal_sms)
            end
          end
        end
       end
    redirect_to :action => :completed_crud_conversion
  end

  def update_sms_in_classroom_dashboards
    all_dashboards = IfaDashboard.find(:all, :conditions => ["ifa_dashboardable_type = ?", "Classroom"]) 
    all_dashboards.each do |db|
       org = Organization.find_by_id(db.organization_id) rescue nil
       subject = ActSubject.find_by_id(db.act_subject_id)
       if org && (db.period_end > Date.today - 2.months)
         entity = Classroom.find_by_id(db.ifa_dashboardable_id)
         if entity
            db.ifa_dashboard_sms_scores.each do |scores|
              fin_sms = scores.act_master.sms_for_period(entity, subject, db.period_end, org.ifa_org_option.sms_h_threshold, false)
              cal_sms = scores.act_master.sms_for_period(entity, subject, db.period_end, org.ifa_org_option.sms_h_threshold, true)
              scores.update_attributes(:sms_finalized => fin_sms, :sms_calibrated => cal_sms)
            end
          end
         end
       end
    redirect_to :action => :completed_crud_conversion
  end

  def update_sms_in_user_dashboards
    all_dashboards = IfaDashboard.find(:all, :conditions => ["ifa_dashboardable_type = ?", "User"]) 
    all_dashboards.each do |db|
       org = Organization.find_by_id(db.organization_id) rescue nil
       org = Organization.find_by_id(db.organization_id) rescue nil
       subject = ActSubject.find_by_id(db.act_subject_id)
       if org && (db.period_end > Date.today - 2.months)
         entity = User.find_by_id(db.ifa_dashboardable_id) rescue nil
         if entity
            db.ifa_dashboard_sms_scores.each do |scores|
              fin_sms = scores.act_master.sms_for_period(entity, subject, db.period_end, org.ifa_org_option.sms_h_threshold, false)
              cal_sms = scores.act_master.sms_for_period(entity, subject, db.period_end, org.ifa_org_option.sms_h_threshold, true)
              scores.update_attributes(:sms_finalized => fin_sms, :sms_calibrated => cal_sms)
            end
          end
        end
       end
    redirect_to :action => :completed_crud_conversion
  end

  def add_period_end_to_ifa_question_log
#    all_logs = IfaQuestionLog.all 
 #   all_logs.each do |ql|
#       ql.update_attributes (:period_end => ql.date_taken.at_end_of_month)
#   end
    redirect_to :action => :completed_crud_conversion
  end

  def assign_students
    users = User.find(:all)
    users.each do |user|
      if user.has_authorization_level?("participant") 
        user.update_attributes(:is_student => true)
      else
        user.update_attributes(:is_student => false)        
      end
    end
    redirect_to :action => :completed_crud_conversion
  end

  def initialize_q_log_student_baseline
# initialize all Baselines in performance log
#    IfaQuestionPerformance.find(:all).each do |p|
#      p.update_attributes(:baseline_students => 0, :baseline_answers => 0, :baseline_points => 0.0)
#   end
    redirect_to :action => :completed_crud_conversion
  end
  
  def add_grade_csap_to_ifa_question_log
    questions = IfaQuestionLog.find(:all)
    questions.each do |q|
      grade_level = q.user.current_grade_level
      csap = q.user.student_subject_demographics.for_subject(q.act_subject).first.latest_csap rescue nil
      q.update_attributes(:grade_level=>grade_level, :csap => csap)
    end
    redirect_to :action => :completed_crud_conversion
  end

  def q_log_student_csap
    begin_id = params[:q_log][:b_id].empty? ? IfaQuestionLog.first.id : params[:q_log][:b_id].to_i
    end_id = params[:q_log][:e_id].empty? ? IfaQuestionLog.last.id : params[:q_log][:e_id].to_i
    IfaQuestionLog.between_these(begin_id, end_id).each do |q|
      grade_level = q.user.current_grade_level
      csap = q.user.student_subject_demographics.for_subject(q.act_subject).first.latest_csap rescue nil
      q.update_attributes(:grade_level=>grade_level, :csap => csap)

    end
    redirect_to :action => :completed_crud_conversion
  end

  def q_log_grade_0_to_nil

    IfaQuestionLog.grade_zero.each do |q|
      q.update_attributes(:grade_level=>nil)
    end
    redirect_to :action => :completed_crud_conversion
  end

  
  def q_perf_baselines_recalc
#    unless params[:q_log][:ass_id].empty?
#    assessment = ActAssessment.find_by_id(params[:q_log][:ass_id]) rescue nil
#    if assessment
#        mstr = ActMaster.first
#        subject = assessment.act_subject
#        assessment.act_questions.each do |q|
#          q.ifa_question_performances.each do |qp|
#            qp.update_attributes(:baseline_students => 0, :baseline_answers => 0, :baseline_points => 0.0)
#          end
#        end
#          assessment.ifa_question_logs.each do |ql|
#          q_earned_points = ql.earned_points
#          q_answers = ql.choices         
#          student_latest_dashboard = ql.user.ifa_dashboards.for_subject(subject).last rescue nil
#          unless student_latest_dashboard.nil?
#            student_latest_scores = student_latest_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first 
#            baseline_score = student_latest_scores.baseline_score
#          else 
#            baseline_score = ql.user.ifa_user_baseline_scores.for_subject(subject).for_standard(mstr).first.score rescue nil
#          end
#          if baseline_score
#          student_baseline_range = ActScoreRange.for_standard(mstr).for_subject_sms(subject, baseline_score).first 
#          question_range_base_student = ql.act_question.ifa_question_performances.for_range(student_baseline_range).first rescue nil
#          if student_baseline_range
#            if question_range_base_student
#              question_range_base_student.baseline_students += 1
#              question_range_base_student.baseline_answers += q_answers
#              question_range_base_student.baseline_points += q_earned_points
#              question_range_base_student.update_attributes(params[:ifa_question_performance])
#            else
#              question_range_base_student = IfaQuestionPerformance.new
#              question_range_base_student.act_score_range_id = student_baseline_range.id
#              question_range_base_student.students = 0
#              question_range_base_student.points = 0.0
#              question_range_base_student.answers = 0
#              question_range_base_student.calibrated_students = 0
#              question_range_base_student.calibrated_student_answers = 0  
#              question_range_base_student.calibrated_student_points = 0.0
#              question_range_base_student.baseline_students = 1
#              question_range_base_student.baseline_answers = q_answers  
#              question_range_base_student.baseline_points = q_earned_points
#              ql.act_question.ifa_question_performances << question_range_base_student
#            end 
#          end   # end condition if student has existing baseline score          
#          end   # end valid baseline score
#          end
#
#     end
#   end
    redirect_to :action => :completed_crud_conversion   
  end
  
  def dashboard_cells_recalc
    unless params[:q_log][:ass_id].empty?
     assessment = ActAssessment.find_by_id(params[:q_log][:ass_id]) rescue nil
    if assessment
        assessment.act_submissions.each do |sub|
             user_dashboard = sub.user.ifa_dashboards.for_subject(sub.act_subject).for_period(sub.created_at.to_date.at_end_of_month).first 
             user_dashboardable_id = sub.user_id
             classroom_dashboard = sub.classroom.ifa_dashboards.for_subject(sub.act_subject).for_period(sub.created_at.to_date.at_end_of_month).first 
             classroom_dashboardable_id = sub.classroom_id
             org_dashboard = sub.organization.ifa_dashboards.for_subject(sub.act_subject).for_period(sub.created_at.to_date.at_end_of_month).first 
             org_dashboardable_id = sub.organization_id

             unless user_dashboard.ifa_dashboard_cells.size > 0             
 
             ifa_org_option = Organization.find_by_id(org_dashboardable_id).ifa_org_option rescue nil
             if ifa_org_option
                ifa_org_option.act_masters.each do |mstr|
                  sub.ifa_question_logs.each do |log|
                    q_range = log.act_question.act_score_ranges.for_standard(mstr).first rescue nil
                    q_strand = log.act_question.act_standards.for_standard(mstr).first rescue nil
                    if q_range && q_strand
# user
                      dashboard_cell = user_dashboard.ifa_dashboard_cells.with_range_id(q_range.id).with_strand_id(q_strand.id).first 
                      unless dashboard_cell
                        dashboard_cell = IfaDashboardCell.new
                        dashboard_cell.act_master_id = mstr.id
                        dashboard_cell.act_score_range_id = q_range.id
                        dashboard_cell.act_standard_id = q_strand.id
                        dashboard_cell.finalized_answers = log.choices
                        dashboard_cell.calibrated_answers = log.is_calibrated ? log.choices : 0                  
                        dashboard_cell.fin_points = log.earned_points
                        dashboard_cell.cal_points = log.is_calibrated ? log.earned_points : 0.0
                       user_dashboard.ifa_dashboard_cells << dashboard_cell
                      else
                        dashboard_cell.finalized_answers += log.choices
                        dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0                  
                        dashboard_cell.fin_points += log.earned_points
                        dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0 
                        dashboard_cell.update_attributes(params[:ifa_dashboard_cell]) 
                      end
                      
                      entity = sub.user
                                                         
                      dashboard_sms = user_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first
                      up_to_date = Date.today
                      since_date = (up_to_date - sub.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
                      h_threshold = sub.organization.ifa_org_option.sms_h_threshold rescue 0.75
                      unless dashboard_sms
                        dashboard_sms = IfaDashboardSmsScore.new
                        dashboard_sms.act_master_id = mstr.id
                        dashboard_sms.score_range_min = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
                        dashboard_sms.score_range_max = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
                        dashboard_sms.sms_finalized = mstr.sms_for_period(entity, sub.act_subject, user_dashboard.period_end, h_threshold, false)
                        dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, sub.act_subject, user_dashboard.period_end, h_threshold, true)
                        dashboard_sms.baseline_score = mstr.base_score(entity, sub.act_subject)
                        user_dashboard.ifa_dashboard_sms_scores << dashboard_sms            
                      else
                        new_min = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
                        if (new_min < dashboard_sms.score_range_min && new_min != 0) then dashboard_sms.score_range_min = new_min end 
                        new_max =  sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
                        if (new_max > dashboard_sms.score_range_max && new_max != 0) then dashboard_sms.score_range_max =  new_max end 
                          dashboard_sms.sms_finalized = mstr.sms_for_period(entity, sub.act_subject, user_dashboard.period_end, h_threshold, false)
                          dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, sub.act_subject, user_dashboard.period_end, h_threshold, true)
                          dashboard_sms.baseline_score = mstr.base_score(entity, sub.act_subject)
                          dashboard_sms.update_attributes(params[:ifa_dashboard_sms_score]) 
                      end 

# classroom
                       dashboard_cell = classroom_dashboard.ifa_dashboard_cells.with_range_id(q_range.id).with_strand_id(q_strand.id).first 
                      unless dashboard_cell
                        dashboard_cell = IfaDashboardCell.new
                        dashboard_cell.act_master_id = mstr.id
                        dashboard_cell.act_score_range_id = q_range.id
                        dashboard_cell.act_standard_id = q_strand.id
                        dashboard_cell.finalized_answers = log.choices
                        dashboard_cell.calibrated_answers = log.is_calibrated ? log.choices : 0                  
                        dashboard_cell.fin_points = log.earned_points
                        dashboard_cell.cal_points = log.is_calibrated ? log.earned_points : 0.0
                       classroom_dashboard.ifa_dashboard_cells << dashboard_cell
                      else
                        dashboard_cell.finalized_answers += log.choices
                        dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0                  
                        dashboard_cell.fin_points += log.earned_points
                        dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0 
                        dashboard_cell.update_attributes(params[:ifa_dashboard_cell]) 
                      end

                      entity = sub.classroom
                                                         
                      dashboard_sms = classroom_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first
                      up_to_date = Date.today
                      since_date = (up_to_date - sub.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
                      h_threshold = sub.organization.ifa_org_option.sms_h_threshold rescue 0.75
                      unless dashboard_sms
                        dashboard_sms = IfaDashboardSmsScore.new
                        dashboard_sms.act_master_id = mstr.id
                        dashboard_sms.score_range_min = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
                        dashboard_sms.score_range_max = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
                        dashboard_sms.sms_finalized = mstr.sms_for_period(entity, sub.act_subject, classroom_dashboard.period_end, h_threshold, false)
                        dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, sub.act_subject, classroom_dashboard.period_end, h_threshold, true)
                        dashboard_sms.baseline_score = mstr.base_score(entity, sub.act_subject)
                        classroom_dashboard.ifa_dashboard_sms_scores << dashboard_sms            
                      else
                        new_min = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
                        if (new_min < dashboard_sms.score_range_min && new_min != 0) then dashboard_sms.score_range_min = new_min end 
                        new_max =  sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
                        if (new_max > dashboard_sms.score_range_max && new_max != 0) then dashboard_sms.score_range_max =  new_max end 
                          dashboard_sms.sms_finalized = mstr.sms_for_period(entity, sub.act_subject, classroom_dashboard.period_end, h_threshold, false)
                          dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, sub.act_subject, classroom_dashboard.period_end, h_threshold, true)
                          dashboard_sms.baseline_score = mstr.base_score(entity, sub.act_subject)
                          dashboard_sms.update_attributes(params[:ifa_dashboard_sms_score]) 
                      end 


# org 
                        dashboard_cell = org_dashboard.ifa_dashboard_cells.with_range_id(q_range.id).with_strand_id(q_strand.id).first 
                      unless dashboard_cell
                        dashboard_cell = IfaDashboardCell.new
                        dashboard_cell.act_master_id = mstr.id
                        dashboard_cell.act_score_range_id = q_range.id
                        dashboard_cell.act_standard_id = q_strand.id
                        dashboard_cell.finalized_answers = log.choices
                        dashboard_cell.calibrated_answers = log.is_calibrated ? log.choices : 0                  
                        dashboard_cell.fin_points = log.earned_points
                        dashboard_cell.cal_points = log.is_calibrated ? log.earned_points : 0.0
                       org_dashboard.ifa_dashboard_cells << dashboard_cell
                      else
                        dashboard_cell.finalized_answers += log.choices
                        dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0                  
                        dashboard_cell.fin_points += log.earned_points
                        dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0 
                        dashboard_cell.update_attributes(params[:ifa_dashboard_cell]) 
                      end

                      entity = sub.organization
                                                         
                      dashboard_sms = org_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first
                      up_to_date = Date.today
                      since_date = (up_to_date - sub.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
                      h_threshold = sub.organization.ifa_org_option.sms_h_threshold rescue 0.75
                      unless dashboard_sms
                        dashboard_sms = IfaDashboardSmsScore.new
                        dashboard_sms.act_master_id = mstr.id
                        dashboard_sms.score_range_min = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
                        dashboard_sms.score_range_max = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
                        dashboard_sms.sms_finalized = mstr.sms_for_period(entity, sub.act_subject, org_dashboard.period_end, h_threshold, false)
                        dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, sub.act_subject, org_dashboard.period_end, h_threshold, true)
                        dashboard_sms.baseline_score = mstr.base_score(entity, sub.act_subject)
                        org_dashboard.ifa_dashboard_sms_scores << dashboard_sms            
                      else
                        new_min = sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
                        if (new_min < dashboard_sms.score_range_min && new_min != 0) then dashboard_sms.score_range_min = new_min end 
                        new_max =  sub.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
                        if (new_max > dashboard_sms.score_range_max && new_max != 0) then dashboard_sms.score_range_max =  new_max end 
                          dashboard_sms.sms_finalized = mstr.sms_for_period(entity, sub.act_subject, org_dashboard.period_end, h_threshold, false)
                          dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, sub.act_subject, org_dashboard.period_end, h_threshold, true)
                          dashboard_sms.baseline_score = mstr.base_score(entity, sub.act_subject)
                          dashboard_sms.update_attributes(params[:ifa_dashboard_sms_score]) 
                      end 

 
                    end
                  end    # End Log Loop
                 end    # End mstr Loop_
                end  # Org Option Condition

               end    # end Condition for Needed Submission Update

            end # end Submission Loop
         end # end Valid Assessment
    end    # end Parameter Pass Condition
    
    redirect_to :action => :completed_crud_conversion   
  end

  def update_dashboard_cells
    
  end 

  def update_question_performance_baselines
    
  end 

  def update_ifa_question_log
    
  end    
       
  def q_log_student_baseline
#    begin_id = params[:q_log][:b_id].empty? ? IfaQuestionLog.first.id : params[:q_log][:b_id].to_i
#    end_id = params[:q_log][:e_id].empty? ? IfaQuestionLog.last.id : params[:q_log][:e_id].to_i
#    IfaQuestionLog.between_these(begin_id, end_id).each do |q|
#      grade_level = q.user.current_grade_level
#      csap = q.user.student_subject_demographics.for_subject(q.act_subject).first.latest_csap rescue nil
#      q.update_attributes(:grade_level=>grade_level, :csap => csap)
#      q.act_question.ifa_question_performances.each do |qp|
#        subj = qp.act_score_range.act_subject
#        mstr = qp.act_score_range.act_master
#        baseline_score = q.user.ifa_user_baseline_scores.for_subject(subj).for_standard(mstr).first 
#         if baseline_score        
#          if baseline_score.score >= qp.act_score_range.lower_score && baseline_score.score <= qp.act_score_range.upper_score
#            student_count = qp.baseline_students + 1
#            answer_count = qp.baseline_answers + q.choices
#            point_count = qp.baseline_points + q.earned_points
#             qp.update_attributes(:baseline_students=>student_count, :baseline_answers=>answer_count, :baseline_points=>point_count)
#          end
#        end
#       end
#    end
    redirect_to :action => :completed_crud_conversion
  end


  def blog_sequence
#    blogs = Blog.find(:all)
 #   blogs.each do |blog|
 #      blog.update_attributes(:position => blog.id) 
 #  end
 #   posts = BlogPost.find(:all)
 #   posts.each do |post|
 #      post.update_attributes(:position => post.id) 
 #  end
    redirect_to :action => :completed_crud_conversion
  end

  def generate_ifa_question_log
#    all_submissions = ActSubmission.final 
#    all_submissions.each do |sub|
#      sub.act_assessment.act_questions.each do |quest|
#        question_log = IfaQuestionLog.new
#        question_log.act_question_id = quest.id
#        question_log.act_assessment_id = sub.act_assessment_id
#        question_log.act_submission_id = sub.id
#        question_log.user_id = sub.user_id
#        question_log.organization_id = sub.organization_id 
#        question_log.classroom_id = sub.classroom_id        
#        question_log.teacher_id = sub.teacher_id 
#        question_log.act_subject_id = sub.act_subject_id 
 #       question_log.date_taken = sub.created_at
 #       question_log.is_calibrated = quest.is_calibrated
#        question_log.earned_points = sub.act_answers.for_question(quest).collect{|a|a.points}.sum rescue 0.0
 #       question_log.choices =  sub.act_answers.for_question(quest).selected.size  rescue 0    
 #       question_log.save
 #   end
#   end
    redirect_to :action => :completed_crud_conversion
  end


  def act_answers_calibration
#    all_questions = ActQuestion.calibrated
 #   all_questions.each do |q|
 #     q.act_answers.each do |ans|
#        ans.update_attributes (:is_calibrated => true)
#      end
#   end
    redirect_to :action => :completed_crud_conversion
  end

  def content_resource_types_subject_areas
#    all_contents = Content.find(:all)
#    all_contents.each do |c|
#      r_type = ContentResourceType.find(:first, :conditions=> ["name = ?", c.resource_type])
 #     if r_type
 #       c.update_attributes(:content_resource_type_id => r_type.id) 
 #     end
 #     s_area = SubjectArea.find(:first, :conditions => ["name = ?", c.subject_area_old]) rescue nil
 #     if s_area 
 #       c.update_attributes(:subject_area_id => s_area.id) 
 #     end
 #   end
    redirect_to :action => :completed_crud_conversion
  end

  def classroom_subject_areas
#    all_classrooms = Classroom.find(:all)
#    all_classrooms.each do |clsrm|    
#    s_area = SubjectArea.find(:first, :conditions => ["name = ?", clsrm.subject_area_old])rescue nil
#      if s_area
#        clsrm.update_attributes(:subject_area_id => s_area.id) 
#      end
 #   end   
    redirect_to :action => :completed_crud_conversion
  end


  def app_subscriptions
 #   all_organizations = Organization.find(:all)
 #   core = CoopApp.first
 #   ifa = CoopApp.find(:first, :conditions => ["abbrev = ?", "IFA"])
 #   all_organizations.each do |org|
 #     org.coop_apps << core
  #    if org.ifa_org_option
 #       org.coop_apps << ifa
#      end
 #   end
    redirect_to :action => :completed_crud_conversion
  end
 

  def ifa_classroom_options
#    all_classrooms = Classroom.find(:all)
#    all_classrooms.each do |c|
##      unless c.ifa_classroom_option
 #       ifa_option = IfaClassroomOption.new
 #       ifa_option.is_ifa_enabled = false
 #       ifa_option.is_ifa_notify = true
 #       ifa_option.is_ifa_auto_finalize = false
 #       c.ifa_classroom_option = ifa_option
 #     end
 #   end
    redirect_to :action => :completed_crud_conversion
  end

  def update_submission_dashboards
#    all_submissions = ActSubmission.find(:all, :conditions =>["is_final"])
 #   all_submissions.each do |@submission|
#        unless @submission.is_user_dashboarded 
 #         auto_ifa_dashboard_update(@submission.user) 
 #       end
 #       unless @submission.is_classroom_dashboarded 
#          auto_ifa_dashboard_update(@submission.classroom)
 #       end
 #       unless @submission.is_org_dashboarded
 #         auto_ifa_dashboard_update(@submission.organization)
 #       end
 #   end
    redirect_to :action => :completed_crud_conversion
  end
  
  
  
  def gen_question_student_levels
#    all_submissions = ActSubmission.find(:all, :conditions=>["is_final"])
#    IfaStudentLevel.destroy_all
#    all_submissions.each do |sub|
#      student_dashboard = sub.user.ifa_dashboards.for_subject(sub.act_subject).since(sub.created_at).first rescue nil
#    unless student_dashboard 
#      student_dashboard = sub.user.ifa_dashboards.for_subject(sub.act_subject).up_to(sub.created_at).last rescue nil
#    end
 #   if sub.organization.ifa_org_option && student_dashboard
 #     sub.act_assessment.act_questions.each do |quest|
#        sub.organization.ifa_org_option.act_masters.each do |mstr|
#          student_level = IfaStudentLevel.new
#          student_level.act_question_id = quest.id
#          student_level.act_master_id = mstr.id
#          student_level.user_id = sub.user_id
 #         student_level.earned_points = sub.act_answers.for_question(quest).collect{|a|a.points}.sum rescue 0
 #         student_level.choices = sub.act_answers.for_question(quest).selected.size rescue 0
 #         student_level.mastery_level = student_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first.sms_finalized rescue nil
 #         student_level.calibrated_mastery_level = student_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first.sms_calibrated rescue nil
#          student_level.submission_date = sub.created_at
#          student_level.act_submission_id = sub.id
#          if student_level.mastery_level || student_level.calibrated_mastery_level
#            student_level.save
#          end
#        end
#      end
#  end
#  end
    redirect_to :action => :completed_crud_conversion
  end
  
  
  def question_conversion
#    all_questions = ActQuestion.find(:all)
#    all_questions.each do |q|
#      range = ActScoreRange.find_by_id(q.act_score_range_id)
#      stand = ActStandard.find_by_id(q.act_standard_id)
#      q.act_score_ranges<<range
#      q.act_standards<<stand
#    end
  end

  def reading_conversion
 #   all_readings = ActRelReading.find(:all)
 #   all_readings.each do |r|
 #     range = ActScoreRange.find(:first, :condition => ["act_subject_id = ? AND range = ?",r.act_subject_id, r.target_score_range]) rescue nil
 #     if range
 #       new = ActRelReadingActScoreRange.new
 #       new.act_rel_reading_id = r.id
 #       new.act_score_range_id = range.id
 #       new.save
 #       end
 #   end
  end

  def assessment_conversion
#    all_assessments = ActAssessment.find(:all)
#    all_assessments.each do |ass|
#    existing = ActAssessmentScoreRange.find(:first, :condition => ["act_assessment_id = ?", ass.id]) rescue nil
#    unless existing
#      score = ActAssessmentScoreRange.new
#      score.act_assessment_id = ass.id
#      score.standard = "act"
#      score.upper_score = ass.max_question_score("act")
#      score.lower_score = ass.min_question_score("act")
#      score.save
#      end
#    end
  end

  def assessment_calibrations
    all_assessments = ActAssessment.find(:all)
    all_assessments.each do |ass|
      ass.calibrate
    end
  end

  def destroy_question_readings
    all_q_readings = ActQuestionReading.find(:all)
    all_q_readings.each do |qr|
      qr.destroy
    end
  end

  def related_readings_to_questions
    all_readings = ActRelReading.find(:all)
    all_readings.each do |rd|
      rd.act_questions.each do |q|
        existing_reading = ActQuestionReading.find(:first, :condition => ["act_question_id =?", q.id]) rescue nil
        if existing_reading.nil?
          q_reading = ActQuestionReading.new
          q_reading.act_question_id = q.id
          q_reading.reading = rd.reading
          q_reading.save
        end
      end
    end
  end

  def update_points_choices
#    all_submissions = ActSubmission.find(:all)rescue nil
#    all_submissions.each do |sub|
#      if sub.is_final
 #       points = sub.act_answers.collect{|a|a.points}.sum rescue 0
 #       choices = sub.act_answers.selected.size rescue 0
 #       sub.update_attributes(:tot_points => points, :tot_choices => choices)
 #     end
 #   end
 #   user_options = IfaUserOption.find(:all) rescue nil
#    user_options.each do |opt|
#      opt.update_attributes(:beginning_period => Date.today - 3.months)
#    end
  end  

  def system_id_conversion
#    all_users = User.find(:all) rescue nil
#    all_messages.each do |msg|
#    sender = all_users.select{|u| u.full_name == msg.sender}.first rescue nil
#    sndr_id = 825
#    if sender
#      sndr_id = sender.id
#    end
#    clsrm_id = 840
#    if msg.sender == "Megan Bowser"
#      clsrm_id = 16
#      sndr_id = 842
#    end
#    if msg.sender == "Scott Davis"
#      clsrm_id = 12
#      sndr_id = 840
#    end
#    if msg.sender == "Thomas Yates"
#      clsrm_id = 24
#      sndr_id = 947
#    end
#    if msg.sender == "Ruth Lapenna"
#      clsrm_id = 25
#      sndr_id = 950
#    end
#    msg.update_attributes(:classroom_id => clsrm_id, :sender_id => sndr_id)
    end

 #   all_entries = IfaOrgOption.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
##        sys_id = 1
 #     end
#    entry.update_attributes(:act_master_id => sys_id)
#  end
  
#    all_entries = ActBenchType.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end
   
#    all_entries = ActBench.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end
#  
#    all_entries = ActScoreRange.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end

#    all_entries = ActSnapshot.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end  

#    all_entries = ActStandard.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end 
#    
#    all_entries = User.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.std_view == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end
#    
#    all_entries = ActAssessmentScoreRange.find(:all)rescue nil
#    all_entries.each do |entry|
#      if entry.standard == "co"
#        sys_id = 2
#      else 
#        sys_id = 1
#      end
#    entry.update_attributes(:act_master_id => sys_id)
#  end 
#  
 #   all_entries = ActRelReadingActScoreRange.find(:all)rescue nil
#    all_entries.each do |entry|
#     master_id = entry.act_score_range.act_master_id
#    entry.update_attributes(:act_master_id => master_id)
#  end  
#  
#    all_submissions = ActSubmission.find(:all)rescue nil
 #   all_submissions.each do |sub|

 #     score = ActSubmissionScore.new
 #     score.act_submission_id = sub.id
#      score.act_master_id = 1
#      score.est_sms = sub.est_sms
 #     score.final_sms = sub.final_sms
 #     score.save

#    end

#    all_topics = Topic.find(:all)rescue nil
#    all_topics.each do |tpc|
#      if tpc.act_score_range_id
#        score = ActScoreRangeTopic.new
#        score.topic_id = tpc.id
#        score.act_score_range_id = tpc.act_score_range_id
#        score.save
#      end
#    end
 
 
#    all_benches = ActBench.find(:all)rescue nil
#    all_benches.each do |bnch|
#      if bnch.benchmark_type == "evidence"
#        sys_id = 3
#      end 
#      if bnch.benchmark_type == "improvement"
#        sys_id = 2
#      end
#      if bnch.benchmark_type == "benchmark"
#        sys_id = 1
#      end
#    bnch.update_attributes(:act_bench_type_id => sys_id)
#    end



 def eo_import
    @evidences = []
    @status = ""
    if request.post?
      data = params["upload"]["datafile"].read
      
      doc = REXML::Document.new data
      
      @count =0 
      
      begin
        doc.root.each_element('//Test1/item') do |element|
          #Skip first two rows
          if @count > 1
            @evidence = ActBench.new        
            @evidence.act_subject_id = element.elements['ActSubjectId'].get_text
            @evidence.act_standard_id = element.elements['ActStandardId'].get_text
            @evidence.act_score_range_id = element.elements['ActScoreRangeId'].get_text
            @evidence.description = element.elements['Description'].get_text
            @evidence.user_id = element.elements['UserId'].get_text
            @evidence.organization_id = element.elements['OrganizationId'].get_text
            @evidence.standard =  "co"
            @evidence.act_bench_type.name = "evidence"            
            @evidence.co_gle_id =  element.elements['CoGleId'].get_text
            @evidence.save
            @evidences << @evidence
            #          end
          end
          @count += 1
        end 
      rescue => ex
        @status = "ERROR: " + ex.message + "<br/>"
      end
      
    end
  end

  private
  
  def auto_ifa_dashboard_update(entity)
      dashboard_updated = true
      if entity.class.to_s == "User" && !@submission.is_user_dashboarded
        entity_dashboard = @submission.user.ifa_dashboards.for_subject(@submission.act_subject).for_period(@submission.created_at.to_date.at_end_of_month).first 
        dashboardable_id = @submission.user_id
        @submission.update_attributes(:is_user_dashboarded => true)        
      elsif entity.class.to_s == "Classroom" && !@submission.is_classroom_dashboarded
        entity_dashboard = @submission.classroom.ifa_dashboards.for_subject(@submission.act_subject).for_period(@submission.created_at.to_date.at_end_of_month).first 
        dashboardable_id = @submission.classroom_id
        @submission.update_attributes(:is_classroom_dashboarded => true)
      elsif entity.class.to_s == "Organization" && !@submission.is_org_dashboarded
        entity_dashboard = @submission.organization.ifa_dashboards.for_subject(@submission.act_subject).for_period(@submission.created_at.to_date.at_end_of_month).first 
        dashboardable_id = @submission.organization_id
        @submission.update_attributes(:is_org_dashboarded => true) 
      end  
    unless entity_dashboard 
      entity_dashboard = IfaDashboard.new
            entity_dashboard.ifa_dashboardable_id = dashboardable_id
            entity_dashboard.ifa_dashboardable_type = entity.class.to_s
            entity_dashboard.period_end = @submission.created_at.to_date.at_end_of_month
            entity_dashboard.organization_id = @submission.classroom.organization_id
            entity_dashboard.act_subject_id = @submission.act_subject_id
            entity_dashboard.assessments_taken = 1
            entity_dashboard.finalized_assessments = 1
            entity_dashboard.calibrated_assessments = @submission.act_assessment.is_calibrated ? 1: 0
            entity_dashboard.finalized_answers = @submission.act_answers.selected.size rescue 0
            entity_dashboard.calibrated_answers = @submission.act_answers.calibrated.selected.size rescue 0
            entity_dashboard.cal_submission_answers = @submission.act_assessment.is_calibrated ? @submission.act_answers.calibrated.selected.size : 0
            entity_dashboard.finalized_duration = @submission.duration
            entity_dashboard.calibrated_duration = @submission.act_assessment.is_calibrated ?  @submission.duration : 0   
            entity_dashboard.fin_points = @submission.act_answers.collect{|a|a.points}.sum rescue 0.0
            entity_dashboard.cal_points = @submission.act_answers.calibrated.collect{|a|a.points}.sum rescue 0.0       
            entity_dashboard.cal_submission_points = @submission.act_assessment.is_calibrated ? @submission.act_answers.calibrated.collect{|a|a.points}.sum : 0
       entity_dashboard.save   
    else
            entity_dashboard.assessments_taken += 1
            entity_dashboard.finalized_assessments += 1
            entity_dashboard.finalized_answers += @submission.act_answers.selected.size 
            entity_dashboard.calibrated_answers += @submission.act_answers.calibrated.selected.size 
            entity_dashboard.finalized_duration += @submission.duration
            entity_dashboard.fin_points += @submission.act_answers.collect{|a|a.points}.sum 
            entity_dashboard.cal_points += @submission.act_answers.calibrated.collect{|a|a.points}.sum       
            if @submission.act_assessment.is_calibrated
              entity_dashboard.calibrated_assessments += 1
              entity_dashboard.calibrated_duration += @submission.duration              
              entity_dashboard.cal_submission_points += @submission.act_answers.calibrated.collect{|a|a.points}.sum       
              entity_dashboard.cal_submission_answers += @submission.act_answers.calibrated.selected.size             
            end
       entity_dashboard.update_attributes(params[:ifa_dashboard]) 
    end

    ifa_org_option = Organization.find_by_id(entity_dashboard.organization_id).ifa_org_option rescue nil
    if ifa_org_option
      ifa_org_option.act_masters.each do |mstr|
      @submission.ifa_question_logs.each do |log|
          q_range = log.act_question.act_score_ranges.for_standard(mstr).first rescue nil
          q_strand = log.act_question.act_standards.for_standard(mstr).first rescue nil
          if q_range && q_strand
            dashboard_cell = entity_dashboard.ifa_dashboard_cells.for_standard(mstr).with_range_id(q_range.id).with_strand_id(q_strand.id).first 
            unless dashboard_cell
              dashboard_cell = IfaDashboardCell.new
              dashboard_cell.act_master_id = mstr.id
              dashboard_cell.act_score_range_id = q_range.id
              dashboard_cell.act_standard_id = q_strand.id
              dashboard_cell.finalized_answers = log.choices
              dashboard_cell.calibrated_answers = log.is_calibrated ? log.choices : 0                  
              dashboard_cell.fin_points = log.earned_points
              dashboard_cell.cal_points = log.is_calibrated ? log.earned_points : 0.0
#              dashboard_cell.finalized_hover = target_hovers(entity, @submission.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, @submission.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, true)
              entity_dashboard.ifa_dashboard_cells << dashboard_cell
            else
              dashboard_cell.finalized_answers += log.choices
              dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0                  
              dashboard_cell.fin_points += log.earned_points
              dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0 
#              dashboard_cell.finalized_hover = target_hovers(entity, @submission.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, @submission.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, true)
              dashboard_cell.update_attributes(params[:ifa_dashboard_cell]) 
            end
          end
        end    # End Log Loop 
      


        dashboard_sms = entity_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first
        up_to_date = Date.today
        since_date = (up_to_date - @submission.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
        h_threshold = @submission.organization.ifa_org_option.sms_h_threshold rescue 0.75
        unless dashboard_sms
          dashboard_sms = IfaDashboardSmsScore.new
          dashboard_sms.act_master_id = mstr.id
          dashboard_sms.score_range_min = @submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
          dashboard_sms.score_range_max = @submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
          dashboard_sms.sms_finalized = mstr.sms_new(entity, @submission.act_subject, since_date, up_to_date, h_threshold, false)           
          dashboard_sms.sms_calibrated = mstr.sms_new(entity, @submission.act_subject, since_date, up_to_date, h_threshold, true)
          entity_dashboard.ifa_dashboard_sms_scores << dashboard_sms            
        else
          new_min = @submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
          if (new_min < dashboard_sms.score_range_min && new_min != 0) then dashboard_sms.score_range_min = new_min end 
          new_max =  @submission.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
          if (new_max > dashboard_sms.score_range_max && new_max != 0) then dashboard_sms.score_range_max =  new_max end 
          dashboard_sms.sms_finalized = mstr.sms_new(entity, @submission.act_subject, since_date, up_to_date, h_threshold, false)           
          dashboard_sms.sms_calibrated = mstr.sms_new(entity, @submission.act_subject, since_date, up_to_date, h_threshold, true)            
          dashboard_sms.update_attributes(params[:ifa_dashboard_sms_score]) 
        end
    end  # end Master Loop
    end 
 end
  
  protected
  
  def find_submission
    @submission = ActSubmission.find(params[:id]) rescue nil
  end  
end