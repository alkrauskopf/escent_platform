class ActAnswer < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_assessment
  belongs_to :act_submission
  belongs_to :act_question
  belongs_to :act_choice
  belongs_to :user
  belongs_to :organization  
  belongs_to :classroom
  has_one :act_subject, :through => :act_submission
  has_one :mastery_level, :through => :act_question
  has_one :strand, :through => :act_question

  scope :incorrect, :conditions => { :is_correct => false }
  scope :correct, :conditions => { :is_correct => true }
#  scope :selected, :conditions => { :was_selected => true }
  scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}}
  scope :for_teacher, lambda{|teacher| {:conditions => ["teacher_id = ? ", teacher.id]}}
  scope :for_choice, lambda{|choice| {:conditions => ["act_choice_id = ? ", choice.id]}}
  scope :for_assessment, lambda{|assessment| {:conditions => ["act_assessment_id = ? ", assessment.id]}}
  scope :for_submission, lambda{|submission| {:conditions => ["act_submission_id = ? ", submission.id]}}
  scope :for_question, lambda{|question| {:conditions => ["act_question_id = ? ", question.id]}}
  scope :calibrated, :conditions => { :is_calibrated => true }


  SCORES = [
      [ "0%", 0 ],
      [ "50%", 50 ],
      [ "100%", 100 ]
  ]

  def self.not_selected
    where('was_selected = ?', false)
  end

  def self.selected_level_strand(level, strand)
    where("was_selected").select{|a| a.mastery_level == level && a.strand == strand}
  end
  def self.selected
    where('was_selected')
  end

  def self.answer_choices(question)
    where('act_question_id = ? && was_selected', question.id).map{|a| a.act_choice}
  end
  def self.short_answer(question)
    where('act_question_id = ? && was_selected', question.id).first rescue nil
  end
  def self.selected_and_after(after_date)
    where('created_at >= ? AND was_selected', after_date)
  end

  def self.selected_for_subject_window(subject, begin_date, end_date)
    where('created_at >= ? AND created_at <= ? AND was_selected', begin_date, end_date).select{|a| a.act_subject == subject}
  end
  def self.selected_for_subject_since(subject, begin_date)
    where('created_at >= ? AND was_selected', begin_date).select{|a| a.act_subject == subject}
  end

  def cell_answers (answers, standard_id, range_id)
    act_standard = ActStandard.find_by_id(standard_id) rescue nil
    act_score_range = ActScoreRange.find_by_id(range_id) rescue nil
     if answers && act_standard && act_score_range
#         cell_answers = answers.select{|a| a.act_question.act_standard_id == standard_id && a.act_question.act_score_range_id == range_id}  
         cell_answers = answers.select{|a| act_standard.act_questions.include?(a.act_question) && act_score_range.act_questions.include?(a.act_question)}    
     else
       cell_answer = []
     end
  end

  def mastery_level
    self.act_question.mastery_level
  end

  def strand
    self.act_question.strand
  end


  def target_students(answers, target)

    students = answers.collect{|a| a.user_id}.uniq
    @num_students = 0
    target_students = ""
    students.each do |s|
     stu_ans = answers.select{|a| a.user_id == s}
     stu_points = stu_ans.sum{|a| a.points}
     if (100*stu_points/stu_ans.size <= target) 
      @num_students += 1
      user = User.find_by_id(s) rescue nil    
      if user
        unless target_students.empty? 
          target_students += ", " + user.last_name
        else
          target_students += user.last_name
        end
      end
     end
    end 
  student_label = @num_students == 1 ? " Student " : " Students "
  hover_string = "<strong/>" + @num_students.to_s + student_label + "Below " + target.to_s + "%</strong><br/>" + target_students
  end

  def target_classrooms(answers, target)

    classrooms = answers.collect{|a| a.classroom_id}.uniq
    target_classrooms = ""
    classrooms.each do |c|
      classroom = Classroom.find_by_id(c) rescue nil
      if classroom
        classroom_name = classroom.course_name
        classroom_leaders = classroom.teacher_list
        cls_ans = answers.select{|a| a.classroom_id == c}
        cls_points = cls_ans.sum{|a| a.points}
        cls_pct = (100*cls_points/cls_ans.size).to_i
        classroom_string = cls_pct > target ? (cls_pct.to_s + "% " + classroom_name + ": " + classroom_leaders + "<br/>") : ("<strong>" + cls_pct.to_s + "% " + classroom_name + ": " + classroom_leaders + "</strong><br/>")
        target_classrooms += classroom_string
      end
    end
  target_classrooms
  end


  def cell_percent (answers, standard_id, range_id)
    
    act_standard = ActStandard.find_by_id(standard_id) rescue nil
    act_score_range = ActScoreRange.find_by_id(range_id) rescue nil
    
    if answers && act_standard && act_score_range
      cell_answers = answers.select{|a| act_standard.act_questions.include?[a.question] && act_score_range.act_questions.include?[a.question]}    
      cell_points = answers.sum{|a| a.points}
    else
      cell_answers = []
    end
    if cell_answers.size >0
        cell_percent = cell_points/cell_answers.size.to_f
    else
        cell_percent = 0
    end
  cell_percent
  end

  def sms_xstats(answers,subject_id, standard_id, range_id, org_id, stats_group, standard)
    
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
          sms_array[idx] =  sms(group_answers,subject_id, standard_id, range_id, org_id, standard)
          pct_array[idx] = group_answers.sum{|a| a.points}/group_answers.size
        end
      end
      if stats_group == "student"
        ans_group_ids = selected_answers.collect{|a|a.user_id}.uniq
        ans_group_ids.each_with_index do |gid, idx| 
          group_answers = selected_answers.select{|a| a.user_id == gid}
          sms_array[idx] = sms(group_answers,subject_id, standard_id, range_id, org_id, standard)
          pct_array[idx] = 100*(group_answers.sum{|a| a.points}/group_answers.size)
        end
      end      
      if stats_group == "classroom"
        ans_group_ids = selected_answers.collect{|a| a.classroom_id}.uniq
        ans_group_ids.each_with_index do |gid, idx|  
          group_answers = selected_answers.select{|a| a.classroom_id == gid}
          sms_array[idx] = sms(group_answers,subject_id, standard_id, range_id, org_id, standard)
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
  sms_xstats = stats
  end


  def sms(answers,subject_id, standard_id, score_range_id, org_id, standard)
    
    act_standard = ActStandard.find_by_id(standard_id) rescue nil
    
    if subject_id && answers
      options = IfaOrgOption.for_org_id(org_id)
# filter answer list  Limit to was_select 
    selected_answers = answers.select{|a| a.was_selected}

#  Filter by Standard
    if act_standard
      selected_answers = selected_answers.select{|a| act_standard.act_questions.include?[a.question]}
    end

# get score ranges
      unless score_range_id == 0
    #    score_ranges = ActScoreRange.find(:all, :conditions => ["act_subject_id = ? AND id = ? AND standard = ?", subject_id, score_range_id, standard])
        score_ranges = ActScoreRange.for_subject_id(subject_id).select{|sr| (sr.standard == standard && sr.id == score_range_id)}
      else
   #     score_ranges = ActScoreRange.find(:all, :conditions => ["act_subject_id = ? AND standard = ?", subject_id, standard])
        score_ranges = ActScoreRange.for_subject_id(subject_id).select{|sr| (sr.standard == standard)}
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

  end
