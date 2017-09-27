class Master::ActSubmissionsController < Master::ApplicationController

  before_filter :find_submission, :only => [:edit, :show, :delete]
  
  def index
    @submissions = ActSubmission.all
  end
 
  def completed_crud_conversion
  end
  
  def new
    redirect_to :action => :index
  end
  
  def edit
    redirect_to :action => :index
  end
  
  def show
    redirect_to :action => :completed_crud_conversion
  end
  
  def delete
    redirect_to :action => :index
  end

  def update_sms_in_org_dashboards
    redirect_to :action => :completed_crud_conversion
  end

  def update_sms_in_classroom_dashboards
    redirect_to :action => :completed_crud_conversion
  end

  def update_sms_in_user_dashboards
    redirect_to :action => :completed_crud_conversion
  end

  def add_period_end_to_ifa_question_log
    redirect_to :action => :completed_crud_conversion
  end

  def assign_students
    redirect_to :action => :completed_crud_conversion
  end

  def initialize_q_log_student_baseline
    redirect_to :action => :completed_crud_conversion
  end
  
  def add_grade_csap_to_ifa_question_log
    redirect_to :action => :completed_crud_conversion
  end

  def q_log_student_csap
   redirect_to :action => :completed_crud_conversion
  end

  def q_log_grade_0_to_nil
    redirect_to :action => :completed_crud_conversion
  end
  
  def q_perf_baselines_recalc
    redirect_to :action => :completed_crud_conversion   
  end
  
  def dashboard_cells_recalc
    if false
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
    end
    redirect_to :action => :completed_crud_conversion   
  end

  def update_dashboard_cells
    redirect_to :action => :completed_crud_conversion
  end 

  def update_question_performance_baselines
    redirect_to :action => :completed_crud_conversion
  end 

  def update_ifa_question_log
    redirect_to :action => :completed_crud_conversion
  end    
       
  def q_log_student_baseline
    redirect_to :action => :completed_crud_conversion
  end

  def blog_sequence
    redirect_to :action => :completed_crud_conversion
  end

  def generate_ifa_question_log
    redirect_to :action => :completed_crud_conversion
  end

  def act_answers_calibration
    redirect_to :action => :completed_crud_conversion
  end

  def content_resource_types_subject_areas
    redirect_to :action => :completed_crud_conversion
  end

  def classroom_subject_areas
    redirect_to :action => :completed_crud_conversion
  end

  def app_subscriptions
    redirect_to :action => :completed_crud_conversion
  end

  def ifa_classroom_options
    redirect_to :action => :completed_crud_conversion
  end

  def update_submission_dashboards
    redirect_to :action => :completed_crud_conversion
  end
  
  def gen_question_student_levels
    redirect_to :action => :completed_crud_conversion
  end
  
  
  def question_conversion
    redirect_to :action => :completed_crud_conversion
  end

  def reading_conversion
    redirect_to :action => :completed_crud_conversion
  end

  def assessment_conversion
    redirect_to :action => :completed_crud_conversion
  end

  def assessment_calibrations
    if false
      all_assessments = ActAssessment.all
      all_assessments.each do |ass|
        ass.calibrate
      end
    end
    redirect_to :action => :completed_crud_conversion
  end

  def destroy_question_readings
    if false
      all_q_readings = ActQuestionReading.all
      all_q_readings.each do |qr|
        qr.destroy
      end
    end
    redirect_to :action => :completed_crud_conversion
  end

  def related_readings_to_questions
   if false
    all_readings = ActRelReading.all
    all_readings.each do |rd|
      rd.act_questions.each do |q|
        existing_reading = q.act_question_reading
        if existing_reading.nil?
          q_reading = ActQuestionReading.new
          q_reading.act_question_id = q.id
          q_reading.reading = rd.reading
          q_reading.save
        end
      end
    end
   end
   redirect_to :action => :completed_crud_conversion
  end

  def update_points_choices
    redirect_to :action => :completed_crud_conversion
  end

  def system_id_conversion
    redirect_to :action => :completed_crud_conversion
  end

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
  
  protected
  
  def find_submission
    @submission = ActSubmission.find(params[:id]) rescue nil
  end  
end