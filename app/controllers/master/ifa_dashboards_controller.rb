class Master::IfaDashboardsController < Master::ApplicationController

  layout "master"
  
  
  def index
  end

  def manual_user_update
  end

  def manual_org_update
  end 
   
  def manual_classroom_update
  end 
  
  def update_user_ifa_dashboards
    
    months_back = 0
    if params[:dashboard_update][:periods]
      months_back = params[:dashboard_update][:periods].to_i
    end
    month_begin = Date.today.at_beginning_of_month - months_back.months 
# Cycle Months
  until month_begin > Date.today
    month_end = month_begin.at_end_of_month



#  Cycle Subjects    
    ifa_subjects = ActSubject.all
    ifa_subjects.each do |subj|
    
    usr_list = User.all
 
#  Cycle Users
        usr_list.each do |usr|
          org_options = IfaOrgOption.find_by_organization_id(usr.organization.id) rescue nil
          if org_options
          sms_date = month_end > Date.today ? (Date.today - org_options.sms_calc_cycle.days) : (month_end - org_options.sms_calc_cycle.days)          
          submissions = usr.act_submissions.for_subject(subj).select{|s| s.created_at >= month_begin && s.created_at <= month_end} rescue []
          submissions_for_sms_calc = usr.act_submissions.for_subject(subj).select{|s| s.created_at >= sms_date && s.created_at <= month_end} rescue []
          finalized_submissions = submissions.select{|sub| sub.is_final} rescue []
          finalized_submissions_for_sms_calc = submissions_for_sms_calc.select{|sub| sub.is_final} rescue []
          calibrated_submissions = finalized_submissions.select{|sub| sub.act_assessment.is_calibrated} rescue []
          calibrated_submissions_for_sms_calc = finalized_submissions_for_sms_calc.select{|sub| sub.act_assessment.is_calibrated} rescue []
          finalized_answers = finalized_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          finalized_answers_for_sms_calc = finalized_submissions_for_sms_calc.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_submission_answers = calibrated_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_answers = finalized_answers.select{|a| a.act_question.is_calibrated} rescue []
          calibrated_answers_for_sms_calc = finalized_answers_for_sms_calc.select{|a| a.act_question.is_calibrated} rescue []

          # user_dashboard = IfaDashboard.find(:first, :conditions => ["ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ? AND act_subject_id = ? AND organization_id = ?", usr.id, usr.class.to_s,  month_end, subj.id, usr.home_org_id]) rescue nil
          user_dashboard = usr.organization.ifa_dashboards.for_subject(subj).where('ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ?', usr.id, usr.class.to_s,  month_end).first
          if user_dashboard
            unless submissions.empty?
              user_dashboard.assessments_taken = submissions.size rescue 0
              user_dashboard.finalized_assessments = finalized_submissions.size rescue 0
              user_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
              user_dashboard.finalized_answers = finalized_answers.size rescue 0
              user_dashboard.calibrated_answers = calibrated_answers.size rescue 0
              user_dashboard.calibrated_submission_answers = calibrated_submission_answers.size rescue 0
              user_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
              user_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
              user_dashboard.finalized_points = finalized_answers.collect{|a| a.points}.sum rescue 0
              user_dashboard.calibrated_points = calibrated_answers.collect{|a| a.points}.sum rescue 0
              user_dashboard.calibrated_submission_points = calibrated_submission_answers.collect{|a| a.points}.sum rescue 0
              user_dashboard.update_attributes  params[:ifa_dashboard]           
            else
              user_dashboard.destroy              
            end
          else
            unless submissions.empty?
              user_dashboard = IfaDashboard.new
              user_dashboard.ifa_dashboardable_id = usr.id
              user_dashboard.ifa_dashboardable_type = usr.class.to_s
              user_dashboard.period_end = month_end
              user_dashboard.organization_id = usr.home_org_id
              user_dashboard.act_subject_id = subj.id
              user_dashboard.assessments_taken = submissions.size rescue 0
              user_dashboard.finalized_assessments = finalized_submissions.size rescue 0
              user_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
              user_dashboard.finalized_answers = finalized_answers.size rescue 0
              user_dashboard.calibrated_answers = calibrated_answers.size rescue 0
              user_dashboard.calibrated_submission_answers = calibrated_submission_answers.size rescue 0
              user_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
              user_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
              user_dashboard.finalized_points = finalized_answers.collect{|a| a.points}.sum rescue 0
              user_dashboard.calibrated_points = calibrated_answers.collect{|a| a.points}.sum rescue 0
              user_dashboard.calibrated_submission_points = calibrated_submission_answers.collect{|a| a.points}.sum rescue 0
              user_dashboard.save
            end
          end

        unless submissions.empty?
#  SMS for each Master Standard
            master_standards = ActMaster.all
            master_standards.each do |mstr|
              master_sms_finalized = 0
              master_sms_calibrated = 0
              assessments = finalized_submissions.collect{|s| s.act_assessment}.compact.uniq rescue []
#    collect. act_assessments from submissions won't work
              min_score = 999999
              max_score = 0
              assessments.each do |a|
                ass_score_range = a.act_assessment_score_range.for_standard(mstr).first
                if ass_score_range
                  if ass_score_range.lower_score < min_score then min_score = ass_score_range.lower_score end
                  if ass_score_range.upper_score > max_score then max_score = ass_score_range.upper_score end
                end
              end

              unless finalized_answers_for_sms_calc.empty?
                master_sms_finalized = mstr.sms(finalized_answers_for_sms_calc, subj.id, 0,0, usr.home_org_id)
              end
              unless calibrated_answers_for_sms_calc.empty?
                master_sms_calibrated = mstr.sms(calibrated_answers_for_sms_calc, subj.id, 0,0, usr.home_org_id)
              end            
              dashboard_score = user_dashboard.ifa_dashboard_sms_scores.select{|s| s.act_master_id == mstr.id}.first rescue nil
              if dashboard_score
                if max_score == 0
                  dashboard_score.destroy
                else
                  dashboard_score.sms_finalized = master_sms_finalized
                  dashboard_score.sms_calibrated = master_sms_calibrated
                  dashboard_score.score_range_min = min_score
                  dashboard_score.score_range_max = max_score
                  dashboard_score.update_attributes params[:ifa_dashboard_sms_score]
                end
              else
                unless max_score == 0
                  dashboard_score = IfaDashboardSmsScore.new
                  dashboard_score.sms_finalized = master_sms_finalized
                  dashboard_score.sms_calibrated = master_sms_calibrated
                  dashboard_score.score_range_min = min_score
                  dashboard_score.score_range_max = max_score
                  dashboard_score.act_master_id = mstr.id
                  user_dashboard.ifa_dashboard_sms_scores << dashboard_score
                end
              end  # End SMS Update       

#  Each Dashboard Cell          
           
              ranges = mstr.act_score_ranges.select{ |r| r.act_subject_id == subj.id} rescue []
              standards = mstr.act_standards.select{ |s| s.act_subject_id == subj.id} rescue []            
              ranges.each do |range|
               unless max_score < range.lower_score || min_score > range.upper_score
                  standards.each do |std|
                    finalized_cell_ans = cell_answers(finalized_answers,std.id, range.id)
                    calibrated_cell_ans = cell_answers(calibrated_answers,std.id, range.id)
                    dashboard_cell = user_dashboard.ifa_dashboard_cells.select{|c| c.act_master_id == mstr.id && c.act_score_range_id == range.id && c.act_standard_id == std.id}.first rescue[]
                    if dashboard_cell
                      if finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                        user_dashboard.ifa_dashboard_cells.delete(dashboard_cell)
                      else
                        dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                        dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
                        dashboard_cell.finalized_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.calibrated_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
   #  doesn't work      user_dashboard.ifa_dashboard_cells.replace(dashboard_cell)
                        dashboard_cell.update_attributes params[:ifa_dashboard_cell]
                      end                    
                    else
                      unless finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                        dashboard_cell = IfaDashboardCell.new
                        dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                        dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
                        dashboard_cell.finalized_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.calibrated_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.act_master_id = mstr.id
                        dashboard_cell.act_score_range_id = range.id
                        dashboard_cell.act_standard_id = std.id              
                        user_dashboard.ifa_dashboard_cells << dashboard_cell
                      end
                    end  # End cell Update
                  end  #  End Column Cycle
                  else
                    range_cells = user_dashboard.ifa_dashboard_cells.where('act_master_id = ? && act_score_range_id = ?', mstr.id, range.id) rescue []
                    range_cells.each do |cell|
                      cell.destroy
                    end
                  end  # Score Range Condition
                end   # End Row Cycle
             end  # End Master Cycle
          end #End If Submission Condition 
        end # End IFA Org Condition
        end  # End Users Cycle

    end # End Subject Cycle
    month_begin += 1.month
  end   # End Month Cycle
 
  redirect_to :action => :manual_user_update
  end

  
  def update_org_ifa_dashboards
    
    months_back = 0
    if params[:dashboard_update][:periods]
      months_back = params[:dashboard_update][:periods].to_i
    end
    month_begin = Date.today.at_beginning_of_month - months_back.months 
# Cycle Months
  until month_begin > Date.today
    month_end = month_begin.at_end_of_month


#  Cycle Subjects    
    ifa_subjects = ActSubject.all
    ifa_subjects.each do |subj|
    
    org_list = Organization.all
 
#  Cycle Organizations
        org_list.each do |org|
          org_options = IfaOrgOption.find_by_organization_id(org.id) rescue nil
          if org_options
          sms_date = month_end > Date.today ? (Date.today - org_options.sms_calc_cycle.days) : (month_end - org_options.sms_calc_cycle.days)          
          
          submissions = org.act_submissions.for_subject(subj).select{|s| s.created_at >= month_begin && s.created_at <= month_end} rescue []
          submissions_for_sms_calc = org.act_submissions.for_subject(subj).select{|s| s.created_at >= sms_date && s.created_at <= month_end} rescue []
          finalized_submissions = submissions.select{|sub| sub.is_final} rescue []
          finalized_submissions_for_sms_calc = submissions_for_sms_calc.select{|sub| sub.is_final} rescue []
          calibrated_submissions = finalized_submissions.select{|sub| sub.act_assessment.is_calibrated} rescue []
          calibrated_submissions_for_sms_calc = finalized_submissions_for_sms_calc.select{|sub| sub.act_assessment.is_calibrated} rescue []
          finalized_answers = finalized_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          finalized_answers_for_sms_calc = finalized_submissions_for_sms_calc.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_submission_answers = calibrated_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_answers = finalized_answers.select{|a| a.act_question.is_calibrated} rescue []
          calibrated_answers_for_sms_calc = finalized_answers_for_sms_calc.select{|a| a.act_question.is_calibrated} rescue []
           
          # org_dashboard = IfaDashboard.find(:first, :conditions => ["ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ? AND act_subject_id = ? ", org.id, org.class.to_s,  month_end, subj.id]) rescue nil
          org_dashboard = subj.ifa_dashboards.where('ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ?', org.id, org.class.to_s,  month_end).first rescue nil
          if org_dashboard
            unless submissions.empty?
              org_dashboard.assessments_taken = submissions.size rescue 0
              org_dashboard.finalized_assessments = finalized_submissions.size rescue 0
              org_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
              org_dashboard.finalized_answers = finalized_answers.size rescue 0
              org_dashboard.calibrated_answers = calibrated_answers.size rescue 0
              org_dashboard.calibrated_submission_answers = calibrated_submission_answers.size rescue 0
              org_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
              org_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
              org_dashboard.finalized_points = finalized_answers.collect{|a| a.points}.sum rescue 0
              org_dashboard.calibrated_points = calibrated_answers.collect{|a| a.points}.sum rescue 0
              org_dashboard.calibrated_submission_points = calibrated_submission_answers.collect{|a| a.points}.sum rescue 0
              org_dashboard.update_attributes  params[:ifa_dashboard]           
            else
              org_dashboard.destroy              
            end
          else
            unless submissions.empty?
              org_dashboard = IfaDashboard.new
              org_dashboard.ifa_dashboardable_id = org.id
              org_dashboard.ifa_dashboardable_type = org.class.to_s
              org_dashboard.period_end = month_end
              org_dashboard.organization_id = org.id
              org_dashboard.act_subject_id = subj.id
              org_dashboard.assessments_taken = submissions.size rescue 0
              org_dashboard.finalized_assessments = finalized_submissions.size rescue 0
              org_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
              org_dashboard.finalized_answers = finalized_answers.size rescue 0
              org_dashboard.calibrated_answers = calibrated_answers.size rescue 0
              org_dashboard.calibrated_submission_answers = calibrated_submission_answers.size rescue 0
              org_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
              org_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
              org_dashboard.finalized_points = finalized_answers.collect{|a| a.points}.sum rescue 0
              org_dashboard.calibrated_points = calibrated_answers.collect{|a| a.points}.sum rescue 0
              org_dashboard.calibrated_submission_points = calibrated_submission_answers.collect{|a| a.points}.sum rescue 0
              org_dashboard.save
            end
          end

        unless submissions.empty?
#  SMS for each Master Standard
            master_standards = ActMaster.all
            master_standards.each do |mstr|
              master_sms_finalized = 0
              master_sms_calibrated = 0
              assessments = finalized_submissions.collect{|s| s.act_assessment}.compact.uniq rescue []
#    collect. act_assessments from submissions won't work
              min_score = 999999
              max_score = 0
              assessments.each do |a|
                ass_score_range = a.act_assessment_score_ranges.for_standard(mstr).first rescue nil
                if ass_score_range
                  if ass_score_range.lower_score < min_score then min_score = ass_score_range.lower_score end
                  if ass_score_range.upper_score > max_score then max_score = ass_score_range.upper_score end
                end
              end

              unless finalized_answers_for_sms_calc.empty?
                master_sms_finalized = mstr.sms(finalized_answers_for_sms_calc, subj.id, 0,0, org.id)
              end
              unless calibrated_answers_for_sms_calc.empty?
                master_sms_calibrated = mstr.sms(calibrated_answers_for_sms_calc, subj.id, 0,0, org.id)
              end            
              dashboard_score = org_dashboard.ifa_dashboard_sms_scores.select{|s| s.act_master_id == mstr.id}.first rescue nil
              if dashboard_score
                if max_score == 0
                  dashboard_score.destroy
                else
                  dashboard_score.sms_finalized = master_sms_finalized
                  dashboard_score.sms_calibrated = master_sms_calibrated
                  dashboard_score.score_range_min = min_score
                  dashboard_score.score_range_max = max_score
                  dashboard_score.update_attributes params[:ifa_dashboard_sms_score]
                end
              else
                unless max_score == 0
                  dashboard_score = IfaDashboardSmsScore.new
                  dashboard_score.sms_finalized = master_sms_finalized
                  dashboard_score.sms_calibrated = master_sms_calibrated
                  dashboard_score.score_range_min = min_score
                  dashboard_score.score_range_max = max_score
                  dashboard_score.act_master_id = mstr.id
                  org_dashboard.ifa_dashboard_sms_scores << dashboard_score
                end
              end  # End SMS Update       

#  Each Dashboard Cell          
           
              ranges = mstr.act_score_ranges.select{ |r| r.act_subject_id == subj.id} rescue []
              standards = mstr.act_standards.select{ |s| s.act_subject_id == subj.id} rescue []            
              ranges.each do |range|
               unless max_score < range.lower_score || min_score > range.upper_score
                  standards.each do |std|
                    finalized_cell_ans = cell_answers(finalized_answers,std.id, range.id)
                    calibrated_cell_ans = cell_answers(calibrated_answers,std.id, range.id)
                    dashboard_cell = org_dashboard.ifa_dashboard_cells.select{|c| c.act_master_id == mstr.id && c.act_score_range_id == range.id && c.act_standard_id == std.id}.first rescue[]
                    if dashboard_cell
                      if finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                        org_dashboard.ifa_dashboard_cells.delete(dashboard_cell)
                      else
                        dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                        dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
                        dashboard_cell.finalized_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.calibrated_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
   #  doesn't work      user_dashboard.ifa_dashboard_cells.replace(dashboard_cell)
                        dashboard_cell.update_attributes params[:ifa_dashboard_cell]
                      end                    
                    else
                      unless finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                        dashboard_cell = IfaDashboardCell.new
                        dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                        dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
                        dashboard_cell.finalized_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.calibrated_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.act_master_id = mstr.id
                        dashboard_cell.act_score_range_id = range.id
                        dashboard_cell.act_standard_id = std.id              
                        org_dashboard.ifa_dashboard_cells << dashboard_cell
                      end
                    end  # End cell Update
                  end  #  End Column Cycle
                  else
                    range_cells = org_dashboard.ifa_dashboard_cells.where('act_master_id = ? && act_score_range_id = ?',  mstr.id, range.id) rescue []
                    range_cells.each do |cell|
                      cell.destroy
                    end
                  end  # Score Range Condition
                end   # End Row Cycle
             end  # End Master Cycle
          end #End If Submission Condition 
        end # End IFA Org condition
        end  # End Orgs Cycle

    end # End Subject Cycle
    month_begin += 1.month
  end   # End Month Cycle
 
  redirect_to :action => :manual_org_update
  end


  def update_classroom_ifa_dashboards
    
    months_back = 0
    if params[:dashboard_update][:periods]
      months_back = params[:dashboard_update][:periods].to_i
    end
    month_begin = Date.today.at_beginning_of_month - months_back.months 
# Cycle Months
  until month_begin > Date.today
    month_end = month_begin.at_end_of_month


#  Cycle Subjects    
    ifa_subjects = ActSubject.all
    ifa_subjects.each do |subj|
    
    clsrm_list = Classroom.all
 
#  Cycle Classrooms
        clsrm_list.each do |clsrm|
          org_options = IfaOrgOption.find_by_organization_id(clsrm.organization.id) rescue nil
          if org_options
          sms_date = month_end > Date.today ? (Date.today - org_options.sms_calc_cycle.days) : (month_end - org_options.sms_calc_cycle.days)          
          
          submissions = clsrm.act_submissions.for_subject(subj).select{|s| s.created_at >= month_begin && s.created_at <= month_end} rescue []
          submissions_for_sms_calc = clsrm.act_submissions.for_subject(subj).select{|s| s.created_at >= sms_date && s.created_at <= month_end} rescue []
          finalized_submissions = submissions.select{|sub| sub.is_final} rescue []
          finalized_submissions_for_sms_calc = submissions_for_sms_calc.select{|sub| sub.is_final} rescue []
          calibrated_submissions = finalized_submissions.select{|sub| sub.act_assessment.is_calibrated} rescue []
          calibrated_submissions_for_sms_calc = finalized_submissions_for_sms_calc.select{|sub| sub.act_assessment.is_calibrated} rescue []
          finalized_answers = finalized_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          finalized_answers_for_sms_calc = finalized_submissions_for_sms_calc.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_submission_answers = calibrated_submissions.collect{|sub| sub.act_answers}.flatten.select{|a| a.was_selected} rescue []
          calibrated_answers = finalized_answers.select{|a| a.act_question.is_calibrated} rescue []
          calibrated_answers_for_sms_calc = finalized_answers_for_sms_calc.select{|a| a.act_question.is_calibrated} rescue []

          # clsrm_dashboard = IfaDashboard.find(:first, :conditions => ["ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ? AND act_subject_id = ? AND organization_id = ?", clsrm.id, clsrm.class.to_s,  month_end, subj.id, clsrm.organization.id]) rescue nil
          clsrm_dashboard = clsrm.organization.nil? ? nil : clsrm.organization.ifa_dashboards.for_subject(subj).where('ifa_dashboardable_id = ? AND ifa_dashboardable_type = ?  AND period_end = ?', clsrm.id, clsrm.class.to_s,  month_end) rescue nil
          if clsrm_dashboard
            unless submissions.empty?
              clsrm_dashboard.assessments_taken = submissions.size rescue 0
              clsrm_dashboard.finalized_assessments = finalized_submissions.size rescue 0
              clsrm_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
              clsrm_dashboard.finalized_answers = finalized_answers.size rescue 0
              clsrm_dashboard.calibrated_answers = calibrated_answers.size rescue 0
              clsrm_dashboard.calibrated_submission_answers = calibrated_submission_answers.size rescue 0
              clsrm_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
              clsrm_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
              clsrm_dashboard.finalized_points = finalized_answers.collect{|a| a.points}.sum rescue 0
              clsrm_dashboard.calibrated_points = calibrated_answers.collect{|a| a.points}.sum rescue 0
              clsrm_dashboard.calibrated_submission_points = calibrated_submission_answers.collect{|a| a.points}.sum rescue 0
              clsrm_dashboard.update_attributes  params[:ifa_dashboard]           
            else
              clsrm_dashboard.destroy              
            end
          else
            unless submissions.empty?
              clsrm_dashboard = IfaDashboard.new
              clsrm_dashboard.ifa_dashboardable_id = clsrm.id
              clsrm_dashboard.ifa_dashboardable_type = clsrm.class.to_s
              clsrm_dashboard.period_end = month_end
              clsrm_dashboard.organization_id = clsrm.organization.id
              clsrm_dashboard.act_subject_id = subj.id
              clsrm_dashboard.assessments_taken = submissions.size rescue 0
              clsrm_dashboard.finalized_assessments = finalized_submissions.size rescue 0
              clsrm_dashboard.calibrated_assessments = calibrated_submissions.size rescue 0
              clsrm_dashboard.finalized_answers = finalized_answers.size rescue 0
              clsrm_dashboard.calibrated_answers = calibrated_answers.size rescue 0
              clsrm_dashboard.calibrated_submission_answers = calibrated_submission_answers.size rescue 0
              clsrm_dashboard.finalized_duration = finalized_submissions.collect{|s| s.duration}.sum rescue 0
              clsrm_dashboard.calibrated_duration = calibrated_submissions.collect{|s| s.duration}.sum rescue 0       
              clsrm_dashboard.finalized_points = finalized_answers.collect{|a| a.points}.sum rescue 0
              clsrm_dashboard.calibrated_points = calibrated_answers.collect{|a| a.points}.sum rescue 0           
              clsrm_dashboard.calibrated_submission_points = calibrated_submission_answers.collect{|a| a.points}.sum rescue 0
              clsrm_dashboard.save
            end
          end

        unless submissions.empty?
#  SMS for each Master Standard
            master_standards = ActMaster.all
            master_standards.each do |mstr|
              master_sms_finalized = 0
              master_sms_calibrated = 0
              assessments = finalized_submissions.collect{|s| s.act_assessment}.compact.uniq rescue []
#    collect. act_assessments from submissions won't work
              min_score = 999999
              max_score = 0
              assessments.each do |a|
                ass_score_range = a.act_assessment_score_ranges.for_standard(mst).first rescue nil
                if ass_score_range
                  if ass_score_range.lower_score < min_score then min_score = ass_score_range.lower_score end
                  if ass_score_range.upper_score > max_score then max_score = ass_score_range.upper_score end
                end
              end

              unless finalized_answers_for_sms_calc.empty?
                master_sms_finalized = mstr.sms(finalized_answers_for_sms_calc, subj.id, 0,0, clsrm.organization.id)
              end
              unless calibrated_answers_for_sms_calc.empty?
                master_sms_calibrated = mstr.sms(calibrated_answers_for_sms_calc, subj.id, 0,0, clsrm.organization.id)
              end            
              dashboard_score = clsrm.organization.id_dashboard.ifa_dashboard_sms_scores.select{|s| s.act_master_id == mstr.id}.first rescue nil
              if dashboard_score
                if max_score == 0
                  dashboard_score.destroy
                else
                  dashboard_score.sms_finalized = master_sms_finalized
                  dashboard_score.sms_calibrated = master_sms_calibrated
                  dashboard_score.score_range_min = min_score
                  dashboard_score.score_range_max = max_score
                  dashboard_score.update_attributes params[:ifa_dashboard_sms_score]
                end
              else
                unless max_score == 0
                  dashboard_score = IfaDashboardSmsScore.new
                  dashboard_score.sms_finalized = master_sms_finalized
                  dashboard_score.sms_calibrated = master_sms_calibrated
                  dashboard_score.score_range_min = min_score
                  dashboard_score.score_range_max = max_score
                  dashboard_score.act_master_id = mstr.id
                  clsrm_dashboard.ifa_dashboard_sms_scores << dashboard_score
                end
              end  # End SMS Update       

#  Each Dashboard Cell          
           
              ranges = mstr.act_score_ranges.select{ |r| r.act_subject_id == subj.id} rescue []
              standards = mstr.act_standards.select{ |s| s.act_subject_id == subj.id} rescue []            
              ranges.each do |range|
               unless max_score < range.lower_score || min_score > range.upper_score
                  standards.each do |std|
                    finalized_cell_ans = cell_answers(finalized_answers,std.id, range.id)
                    calibrated_cell_ans = cell_answers(calibrated_answers,std.id, range.id)
                    dashboard_cell = clsrm_dashboard.ifa_dashboard_cells.select{|c| c.act_master_id == mstr.id && c.act_score_range_id == range.id && c.act_standard_id == std.id}.first rescue[]
                    if dashboard_cell
                      if finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                        clsrm_dashboard.ifa_dashboard_cells.delete(dashboard_cell)
                      else
                        dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                        dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
                        dashboard_cell.finalized_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.calibrated_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
   #  doesn't work      user_dashboard.ifa_dashboard_cells.replace(dashboard_cell)
                        dashboard_cell.update_attributes params[:ifa_dashboard_cell]
                      end                    
                    else
                      unless finalized_cell_ans.size == 0 && calibrated_cell_ans.size == 0
                        dashboard_cell = IfaDashboardCell.new
                        dashboard_cell.finalized_answers = finalized_cell_ans.size rescue 0
                        dashboard_cell.calibrated_answers = calibrated_cell_ans.size rescue 0
                        dashboard_cell.finalized_points = finalized_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.calibrated_points = calibrated_cell_ans.sum{|a| a.points} rescue 0
                        dashboard_cell.act_master_id = mstr.id
                        dashboard_cell.act_score_range_id = range.id
                        dashboard_cell.act_standard_id = std.id              
                        clsrm_dashboard.ifa_dashboard_cells << dashboard_cell
                      end
                    end  # End cell Update
                  end  #  End Column Cycle
                  else
                    range_cells = clsrm_dashboard.ifa_dashboard_cells.where('act_master_id = ? && act_score_range_id = ?',  mstr.id, range.id) rescue []
                    range_cells.each do |cell|
                      cell.destroy
                    end
                  end  # Score Range Condition
                end   # End Row Cycle
             end  # End Master Cycle
          end #End If Submission Condition 
        end # End IFA Org condition
        end  # End Classrooms Cycle

    end # End Subject Cycle
    month_begin += 1.month
  end   # End Month Cycle
 
  redirect_to :action => :manual_classroom_update
  end


end
