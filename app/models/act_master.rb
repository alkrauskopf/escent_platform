class ActMaster < ActiveRecord::Base

  include PublicPersona
  
  has_many :act_benches, :dependent => :destroy
  has_many :act_bench_types, :dependent => :destroy
  has_many :act_snapshots
  has_many :act_score_ranges
  has_many :act_standards
  has_many :act_subjects, :through => :act_standards, :uniq => true  
  has_many :users
  has_many :act_assessment_score_ranges
  has_many :act_rel_reading_act_score_ranges
  has_many :act_submission_scores
  has_many :ifa_dashboard_sms_scores
  has_many :ifa_org_option_act_masters, :dependent => :destroy
  has_many :ifa_org_options, :through => :ifa_org_option_act_masters
  has_many :ifa_student_levels
  has_many :ifa_user_options
  has_many :ifa_classroom_options
  has_many :ifa_user_baseline_scores
  
  
     
  named_scope :national, :conditions => { :is_national => true}  
  named_scope :act, :conditions => { :abbrev => "ACT"}  
  named_scope :all, :order => "abbrev"
  scope       :co,  :conditions => { :abbrev => "CO"}


  def self.find_standard(std)
    self.find(:first, :conditions =>["abbrev = ?", std]) rescue nil
  end

  def sms_for_period(entity, subject,period, h_threshold, calibrated)
    period_end = period.at_end_of_month
    ranges = ActScoreRange.for_standard(self).for_subject(subject).no_na.sort{|a,b| b.upper_score <=> a.upper_score}
    if ranges.size > 0 
      entity_dashboard = entity.ifa_dashboards.for_subject(subject).for_period(period_end).first rescue nil
      score = ranges.last.upper_score
      prev_score = ranges.last.upper_score
      questions_found = false
      baseline_found = false
      ranges.each do |sr|
        range_cells = entity_dashboard.ifa_dashboard_cells.with_range_id(sr.id) rescue []
        unless range_cells.empty?
          questions_found = true
        end 
        total_choices = calibrated ? range_cells.collect{|q| q.calibrated_answers}.compact.sum : range_cells.collect{|q| q.finalized_answers}.compact.sum
        total_points = calibrated ? range_cells.collect{|q| q.cal_points}.compact.sum : range_cells.collect{|q| q.fin_points}.compact.sum
        pct_correct = total_choices == 0? 0.0 : total_points/total_choices
        pct_incorrect = total_choices == 0? 0.0 : (1.0-pct_correct)
        if pct_correct >= h_threshold && !baseline_found
          score = sr.upper_score
          prev_score = sr.upper_score        
          baseline_found = true
        end
        if baseline_found
          score = (score - pct_incorrect*(prev_score - sr.upper_score)) 
          prev_score = sr.upper_score
        else
          prev_score = sr.upper_score
        end
      end
    else
      questions_found = false
      score = 0
    end  

    final_score = questions_found ? score.round.to_i : 0
    
  end

  def base_score(entity, subject)
   if entity.class.to_s == "User"
      baseline = entity.ifa_user_baseline_scores.for_subject(subject).for_standard(self).first rescue nil
      if baseline
        score =  baseline.score ? baseline.score.to_f : 0.0 
      end
   end

# temp bypass
   if entity.class.to_s == "Classroom_xx"
      student_baselines = entity.participants.collect{|u| u.ifa_user_baseline_scores.for_subject(subject).for_standard(self).first rescue nil}.compact
      unless student_baselines.empty?
        score =  student_baselines.collect{|s| s.score}.sum/student_baseline.size 
      else
        score = 0.0
      end
   end

    final_score = score ? score.round.to_i : 0
    
  end


  def sms_new(entity, subject, since_date, up_to_date, h_threshold, calibrate_only)

    ranges = ActScoreRange.for_standard(self).for_subject(subject).no_na.sort{|a,b| b.upper_score <=> a.upper_score}rescue []
    if ranges.size > 0 
      question_log_list = calibrate_only ? entity.ifa_question_logs.for_subject(subject).since(since_date.to_date).up_to(up_to_date.to_date).calibrated :  entity.ifa_question_logs.for_subject(subject).since(since_date.to_date).up_to(up_to_date.to_date)   
      score = ranges.last.upper_score
      prev_score = ranges.last.upper_score
      questions_found = false
      baseline_found = false
      ranges.each do |sr|
        question_log_group = question_log_list.select{|ql| ql.act_question.act_score_ranges.include?(sr)}
        unless question_log_group.empty?
          questions_found = true
        end 
        total_choices = question_log_group.sum{|q| q.choices}
        total_points = question_log_group.sum{|q| q.earned_points}
        pct_correct = total_choices == 0? 0.0 : total_points/total_choices
        pct_incorrect = total_choices == 0? 0.0 : (1.0-pct_correct)
        if pct_correct >= h_threshold && !baseline_found
          score = sr.upper_score
          prev_score = sr.upper_score        
          baseline_found = true
        end
        if baseline_found
          score = (score - pct_incorrect*(prev_score - sr.upper_score)) 
          prev_score = sr.upper_score
        else
          prev_score = sr.upper_score
        end
      end
    else
      questions_found = false
      score = 0
    end  

    final_score = questions_found ? score.round.to_i : 0
  end

  def sms(answers,subject_id, standard_id, score_range_id, org_id)
    
    act_standard = ActStandard.find_by_id(standard_id) rescue nil
    
    if subject_id && answers
      options = IfaOrgOption.find(:first, :conditions => ["organization_id = ?", org_id])

# filter anwer list  Limit to was_select 
    selected_answers = answers.select{|a| a.was_selected}

#  Filter by Standard
    if act_standard
      selected_answers = selected_answers.select{|a| act_standard.act_questions.include?[a.question]}
    end

# get score ranges
      unless score_range_id == 0
        score_ranges = ActScoreRange.find(:all, :conditions => ["act_subject_id = ? AND id = ? AND act_master_id = ?", subject_id, score_range_id, self.id])
      else   
        score_ranges = ActScoreRange.find(:all, :conditions => ["act_subject_id = ? AND act_master_id = ?", subject_id, self.id])    
        score_ranges.sort!{|a,b| a.upper_score <=> b.upper_score}
      end

# Determine Highest Level as Basis
      
      highest_level = 0
      lowest_level = 2000
      total_selections = 0
      total_points = 0
      percent_correct = 0.0
      delta_score = 0.0
      test = 0
      trap = 0
      score_ranges.each_with_index do |sr,idx|
#        answer_group = selected_answers.select{|a| a.act_question.act_score_range_id == sr.id}
        answer_group = selected_answers.select{|a| sr.act_questions.include?(a.act_question)}
        total_selections = answer_group.size.to_f
        unless total_selections == 0.0   # there must be selections in the score range
          if sr.lower_score < lowest_level
            lowest_level = sr.lower_score
          end
          total_points = answer_group.sum{|a| a.points}           
          percent_correct = total_points/total_selections
          unless options.sms_h_threshold > percent_correct 
           highest_level = sr.upper_score
          end
        end
      end

# Apply Discounts to Highest Level
    
    prev_upper = highest_level
    score = highest_level
    score_ranges.reverse.each_with_index do |sr,idx|  # sequence through Highest to Lowest
      unless sr.upper_score >= prev_upper
        answer_group = selected_answers.select{|a| sr.act_questions.include?(a.act_question)}
        total_selections = answer_group.size.to_f
        delta_score = prev_upper - sr.upper_score
        pct_incorrect = 0.0
        unless total_selections == 0.0
          total_points = answer_group.sum{|a| a.points} 
          pct_incorrect = (total_selections - total_points)/total_selections
        end
        score = score - pct_incorrect * delta_score
        prev_upper = sr.upper_score
      end
#        if idx == 0
#            test = highest_level
#            test = prev_upper
#            test = sr.upper_score        
#            test = total_selections       
#            test = delta_score         
#            test = total_points
#            test = pct_incorrect        
#            test = pct_incorrect
#       end
    end
    if score < lowest_level
      score = lowest_level
    end
    if score == 2000
      score = 0
    end
   else  # No Subject Identified
     score = 0
   end
    
    sms = score.to_i
  end


  def sms_stats(answers,subject_id, standard_id, range_id, org_id, stats_group)
    
    act_standard = ActStandard.find_by_id(standard_id) rescue nil
    act_score_range = ActScoreRange.find_by_id(range_id) rescue nil 
    
  stats = [0,0,0,0,0,0,0]     
     if subject_id && answers
       selected_answers = answers.select{|a| a.was_selected}
#  Filter by Standard
       if act_standard
        selected_answers = selected_answers.select{|a| act_standard.act_questions.include?[a.question]}    
       end
# Filter by Score_Range
       if act_score_range
        selected_answers = selected_answers.select{|a| act_score_range.act_questions.include?[a.question]}    
       end 
      sms_array = []
      pct_array = []
      if stats_group == "submission"
        ans_group_ids = selected_answers.collect{|a| a.act_submission_id}.uniq
        ans_group_ids.each_with_index do |gid, idx|  
          group_answers = selected_answers.select{|a| a.act_submission_id == gid}
          sms_array[idx] =  self.sms(group_answers,subject_id, standard_id, range_id, org_id)
          pct_array[idx] = group_answers.sum{|a| a.points}/group_answers.size
        end
      end
      if stats_group == "student"
        ans_group_ids = selected_answers.collect{|a|a.user_id}.uniq
        ans_group_ids.each_with_index do |gid, idx| 
          group_answers = selected_answers.select{|a| a.user_id == gid}
          sms_array[idx] = self.sms(group_answers,subject_id, standard_id, range_id, org_id)
          pct_array[idx] = 100*(group_answers.sum{|a| a.points}/group_answers.size)
        end
      end      
      if stats_group == "classroom"
        ans_group_ids = selected_answers.collect{|a| a.classroom_id}.uniq
        ans_group_ids.each_with_index do |gid, idx|  
          group_answers = selected_answers.select{|a| a.classroom_id == gid}
          sms_array[idx] = self.sms(group_answers,subject_id, standard_id, range_id, org_id)
          pct_array[idx] = group_answers.sum{|a| a.points}/group_answers.size
        end
      end 
      sms_avg = 0
      sms_min = 0
      sms_max = 0
      sms_std = 0.0
      unless sms_array.empty?
        sms_avg = sms_array.sum/sms_array.size
        sms_min =  sms_array.min
        sms_max =  sms_array.max
        if sms_array.size > 1
          sd = 0
          sms_array.each do |s|
            sd += (s - sms_avg)**2
          end
          sms_std = (((sd/(sms_array.size -  1))**0.5)*100).round.to_f / 100
        end
      end
      pct_avg = 0
      pct_min = 0
      pct_max = 0
      pct_std = 0.0
      unless pct_array.empty?
         pct_avg = (pct_array.sum/pct_array.size).to_i
         pct_max = pct_array.max
         pct_min = pct_array.min
         if pct_array.size > 1
           sd = 0
           pct_array.each do |p|
              sd += (p.to_i - pct_avg)**2
           end
           pct_std = (((sd/(pct_array.size -  1))**0.5)*100).round.to_f / 100
         end
       end
        stats = [sms_array.size, sms_min, sms_max, sms_avg, sms_std,pct_min.to_i,pct_max.to_i, pct_avg, pct_std]        
    end
  sms_stats = stats 
  end
 
  def cell_benchmarks(subject_id, standard_id, range_id)
    cell_benchmarks = ""
    types = self.act_bench_types rescue nil
    
    if types 
      types.each do |t|
        benches = ActBench.find(:all, :conditions => ["act_subject_id =? AND act_standard_id = ? AND act_score_range_id = ? AND act_bench_type_id = ?", subject_id, standard_id, range_id, t.id]) rescue nil
        if benches.size > 0
          cell_benchmarks += "<strong>" +   t.name.upcase + "</strong><br/>"
          benches.each_with_index do |b, idx|
          cell_benchmarks += "<br/>" + (idx+1).to_s + ") " + b.description + "<br/>" 
          end
          cell_benchmarks += "<br/>"
        end
      end
    end
    cell_benchmarks
  end

end
