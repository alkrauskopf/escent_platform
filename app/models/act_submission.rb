class ActSubmission < ActiveRecord::Base

  include PublicPersona


  belongs_to :act_assessment
  belongs_to :user
  belongs_to :classroom
  belongs_to :organization
  belongs_to :act_subject
  belongs_to :teacher, :class_name => 'User', :foreign_key => "teacher_id"
  
  has_many :act_answers, :dependent => :destroy
  has_many :act_submission_scores, :dependent => :destroy
  has_many :ifa_student_levels, :dependent => :destroy
  has_many :ifa_question_logs, :dependent => :destroy
  
  validates_presence_of :teacher_id, :message => 'You Must Identify Your Teacher' 
  
  scope :final, :conditions => { :is_final => true }
  scope :auto_finalized, :conditions => { :is_auto_finalized => true }
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  scope :not_user_dashboarded, :conditions => ["is_user_dashboarded IS NULL"] rescue []
  scope :not_classroom_dashboarded, :conditions => ["is_classroom_dashboarded IS NULL"]rescue []
  scope :not_org_dashboarded, :conditions => ["is_org_dashboarded IS NULL"] rescue []
  scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}}
  scope :for_teacher, lambda{| teacher| {:conditions => ["teacher_id = ?", teacher.id]}}
  scope :for_classroom, lambda{| classroom| {:conditions => ["classroom_id = ?", classroom.id]}}
  scope :for_user, lambda{| user| {:conditions => ["user_id = ?", user.id]}}
  scope :finalized_period, lambda{| period_start, period_end| {:conditions => ["date_finalized >= ? AND date_finalized <= ?", period_start, period_end]}}
  scope :submission_period, lambda{| period_start, period_end| {:conditions => ["created_at >= ? AND created_at <= ?", period_start, period_end]}}
  
  def final?
    self.is_final
  end

  def finalize(auto, reviewer_id)
    finalized = false
    if self.organization.ifa_org_option
      self.act_assessment.act_questions.each do |quest|
        self.log_ifa_question(quest)
      end   # End Question Loop
    end
    self.reviewer_id = reviewer_id
    self.is_auto_finalized = auto
    self.is_final = true
    self.is_user_dashboarded = false
    self.is_org_dashboarded = false
    self.is_classroom_dashboarded = false
    self.date_finalized = Time.now
    self.tot_points = self.total_points
    self.tot_choices = self.total_choices
    self.act_submission_scores.each do |std|
      fin_sms = self.is_auto_finalized ? std.est_sms : self.standard_assessment_score(std.act_master)
      std.update_attributes(:final_sms => fin_sms)
    end
   # if self.update_attributes params[:act_submission]
    if self.save
      # Update User Dashboard Only
      self.auto_ifa_dashboard_update(self.user)
      # Update First Classroom & Org Dashboard of Period
      unless self.period_dashboard?(self.classroom)
        self.auto_ifa_dashboard_update(self.classroom)
      end
      unless self.period_dashboard?(self.organization)
        self.auto_ifa_dashboard_update(self.organization)
      end
      finalized = true
    end
    finalized
  end

  def dashboard_it(dashboard_class)
    self.auto_ifa_dashboard_update(dashboard_class)
  end


  def self.not_dashboarded(dashboard_type, entity, subject, start_date, end_date)
    if dashboard_type == 'User'
      dashboards = entity.act_submissions.for_subject(subject).final.submission_period(start_date, end_date).not_user_dashboarded
    elsif dashboard_type == 'Classroom'
      dashboards = entity.act_submissions.for_subject(subject).final.submission_period(start_date, end_date).not_classroom_dashboarded
    elsif dashboard_type == 'Organization'
      dashboards = entity.act_submissions.for_subject(subject).final.submission_period(start_date, end_date).not_org_dashboarded
    else
      dashboards = []
    end
    dashboards
  end

  def sms_score(std)
    sms_score_record = self.act_submission_scores.for_standard(std).first rescue nil
    if sms_score_record
      score = 0
      if self.final?
        score = sms_score_record.est_sms.nil? ? 0 : sms_score_record.est_sms
      else
        score = sms_score_record.final_sms.nil? ? 0 : sms_score_record.final_sms
      end
    else
      score = 0
    end
    score
  end

  def standard_assessment_score(standard)
    score = 0
    unless self.act_assessment.nil?
      score_pct = (self.tot_choices.nil? || (self.tot_choices == 0) || self.tot_points.nil?) ? 0.0 : (self.tot_points/self.tot_choices.to_f)
      score = standard.lowest_upper_score(self.act_subject)
      if score_pct > 0.25
        delta = (self.act_assessment.upper_score(standard) - standard.lowest_upper_score(self.act_subject)).to_f
        score = standard.lowest_upper_score(self.act_subject) + (delta * score_pct).to_i
      end
    end
    score
  end

  def total_points
    self.act_answers.collect{|a|a.points}.sum rescue 0.0
  end

  def total_choices
    self.act_answers.selected.size rescue 0
  end

  def self.min_max_score(entity, subject, period_end, standard)
    if (entity && subject && standard)
      submissions = entity.act_submissions.for_subject(subject).final.submission_period(period_end.beginning_of_month, period_end)
      assessments = submissions.collect{|s| s.act_assessment}.compact.uniq
      min_max_score = [assessments.collect{|a| a.lower_score(standard)}.min, assessments.collect{|a| a.upper_score(standard)}.max]
    else
      min_max_score = [0,0]
    end
    min_max_score
  end

  def auto_ifa_dashboard_update(entity)
    if entity.class.to_s == "User"
      if self.is_user_dashboarded
        already_dashboarded = true
      else
        already_dashboarded = false
        entity_dashboard = self.user.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first
        dashboardable_id = self.user_id
        self.update_attributes(:is_user_dashboarded => true)
      end
    elsif entity.class.to_s == "Classroom"
      if self.is_classroom_dashboarded
        already_dashboarded = true
      else
        already_dashboarded = false
        entity_dashboard = self.classroom.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first
        dashboardable_id = self.classroom_id
        self.update_attributes(:is_classroom_dashboarded => true)
      end
    elsif entity.class.to_s == "Organization"
      if self.is_org_dashboarded
        already_dashboarded = true
      else
        already_dashboarded = false
        entity_dashboard = self.organization.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first
        dashboardable_id = self.organization_id
        self.update_attributes(:is_org_dashboarded => true)
      end
    end
    unless already_dashboarded
      unless entity_dashboard
        entity_dashboard = IfaDashboard.new
        entity_dashboard.ifa_dashboardable_id = dashboardable_id
        entity_dashboard.ifa_dashboardable_type = entity.class.to_s
        entity_dashboard.period_end = self.created_at.to_date.at_end_of_month
        entity_dashboard.organization_id = self.classroom.organization_id
        entity_dashboard.act_subject_id = self.act_subject_id
        entity_dashboard.assessments_taken = 1
        entity_dashboard.finalized_assessments = 1
        entity_dashboard.calibrated_assessments = self.act_assessment.is_calibrated ? 1: 0
        entity_dashboard.finalized_answers = self.act_answers.selected.size rescue 0
        entity_dashboard.calibrated_answers = self.act_answers.calibrated.selected.size rescue 0
        entity_dashboard.cal_submission_answers = self.act_assessment.is_calibrated ? self.act_answers.calibrated.selected.size : 0
        entity_dashboard.finalized_duration = self.duration
        entity_dashboard.calibrated_duration = self.act_assessment.is_calibrated ?  self.duration : 0
        entity_dashboard.fin_points = self.act_answers.collect{|a|a.points}.sum rescue 0.0
        entity_dashboard.cal_points = self.act_answers.calibrated.collect{|a|a.points}.sum rescue 0.0
        entity_dashboard.cal_submission_points = self.act_assessment.is_calibrated ? self.act_answers.calibrated.collect{|a|a.points}.sum : 0
        entity_dashboard.save
      else
        entity_dashboard.assessments_taken += 1
        entity_dashboard.finalized_assessments += 1
        entity_dashboard.finalized_answers += self.act_answers.selected.size
        entity_dashboard.calibrated_answers += self.act_answers.calibrated.selected.size
        entity_dashboard.finalized_duration += self.duration
        entity_dashboard.fin_points += self.act_answers.collect{|a|a.points}.sum
        entity_dashboard.cal_points += self.act_answers.calibrated.collect{|a|a.points}.sum
        if self.act_assessment.is_calibrated
          entity_dashboard.calibrated_assessments += 1
          entity_dashboard.calibrated_duration += self.duration
          entity_dashboard.cal_submission_points += self.act_answers.calibrated.collect{|a|a.points}.sum
          entity_dashboard.cal_submission_answers += self.act_answers.calibrated.selected.size
        end
        # entity_dashboard.update_attributes(params[:ifa_dashboard])
        entity_dashboard.save
      end

      ifa_org_option = Organization.find_by_id(entity_dashboard.organization_id).ifa_org_option rescue nil
      if ifa_org_option
        ifa_org_option.act_masters.each do |mstr|
          self.ifa_question_logs.each do |log|
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
#              dashboard_cell.finalized_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, true)
                entity_dashboard.ifa_dashboard_cells << dashboard_cell
              else
                dashboard_cell.finalized_answers += log.choices
                dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0
                dashboard_cell.fin_points += log.earned_points
                dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0
#              dashboard_cell.finalized_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard.period_end.beginning_of_month, 75, true)
               # dashboard_cell.update_attributes(params[:ifa_dashboard_cell])
                dashboard_cell.save
              end
            end
          end    # End Log Loop

          dashboard_sms = entity_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first
          up_to_date = Date.today
          since_date = (up_to_date - self.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
          h_threshold = self.organization.ifa_org_option.sms_h_threshold rescue 0.75
          unless dashboard_sms
            dashboard_sms = IfaDashboardSmsScore.new
            dashboard_sms.act_master_id = mstr.id
            dashboard_sms.score_range_min = self.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
            dashboard_sms.score_range_max = self.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
            dashboard_sms.sms_finalized = mstr.sms_for_period(entity, self.act_subject, entity_dashboard.period_ending, h_threshold, false)
            dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, self.act_subject, entity_dashboard.period_ending, h_threshold, true)
            dashboard_sms.baseline_score = mstr.base_score(entity, self.act_subject)
            entity_dashboard.ifa_dashboard_sms_scores << dashboard_sms
          else
            new_min = self.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.lower_score rescue 0
            if (new_min < dashboard_sms.score_range_min && new_min != 0) then dashboard_sms.score_range_min = new_min end
            new_max =  self.act_assessment.act_assessment_score_ranges.for_standard(mstr).first.upper_score rescue 0
            if (new_max > dashboard_sms.score_range_max && new_max != 0) then dashboard_sms.score_range_max =  new_max end
            dashboard_sms.sms_finalized = mstr.sms_for_period(entity, self.act_subject, entity_dashboard.period_ending, h_threshold, false)
            dashboard_sms.sms_calibrated = mstr.sms_for_period(entity, self.act_subject, entity_dashboard.period_ending, h_threshold, true)
            dashboard_sms.baseline_score = mstr.base_score(entity, self.act_subject)
            # dashboard_sms.update_attributes(params[:ifa_dashboard_sms_score])
            dashboard_sms.save
          end
        end  # end Master Loop
      end
    end  # no IFA ORG Options
  end # Already Dashboarded Condition

  def period_dashboard?(entity)
    if entity.class.to_s == 'Organization'
      dashboard = self.organization.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first ? true : false
    elsif entity.class.to_s == 'Classroom'
      dashboard = self.classroom.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first ? true : false
    elsif entity.class.to_s == 'User'
      dashboard = self.user.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first ? true : false
    else
      dashboard = false
    end
    dashboard
  end

  def log_ifa_question(question)
    existing_question = self.ifa_question_logs.for_question(question).first rescue nil
    unless existing_question
      question_log = IfaQuestionLog.new
      question_log.act_question_id = question.id
      question_log.act_assessment_id = self.act_assessment_id
      question_log.act_submission_id = self.id
      question_log.user_id = self.user_id
      question_log.organization_id = self.organization_id
      question_log.classroom_id = self.classroom_id
      question_log.teacher_id = self.teacher_id
      question_log.act_subject_id = self.act_subject_id
      question_log.date_taken = self.created_at
      question_log.period_end = question_log.date_taken.at_end_of_month
      question_log.is_calibrated = question.is_calibrated
      question_log.grade_level = self.user.current_grade_level
      question_log.csap = self.user.student_subject_demographics.for_subject(self.act_subject).first.latest_csap rescue nil
      question_log.earned_points = self.act_answers.for_question(question).collect{|a|a.points}.sum rescue 0.0
      question_log.choices =  self.act_answers.for_question(question).selected.size  rescue 0
      question_log.save

### update Question Performance

      self.organization.ifa_org_option.act_masters.each do |mstr|
        student_latest_dashboard = self.user.ifa_dashboards.for_subject(self.act_subject).last rescue nil
        student_latest_scores = student_latest_dashboard.ifa_dashboard_sms_scores.for_standard(mstr).first rescue nil
        student_range = ActScoreRange.for_standard(mstr).for_subject_sms(self.act_subject, student_latest_scores.sms_finalized).first rescue nil
        question_range_student = question.ifa_question_performances.for_range(student_range).first rescue nil
        q_earned_points = self.act_answers.for_question(question).collect{|a|a.points}.sum rescue 0.0
        q_answers = self.act_answers.for_question(question).selected.size  rescue 0

        if student_range
          if question_range_student
            question_range_student.students += 1
            question_range_student.answers += q_answers
            question_range_student.points += q_earned_points
            # question_range_student.update_attributes(params[:ifa_question_performance])
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
        student_calibrated_range = ActScoreRange.for_standard(mstr).for_subject_sms(self.act_subject, student_latest_scores.sms_calibrated).first rescue nil
        question_range_cal_student = question.ifa_question_performances.for_range(student_calibrated_range).first rescue nil
        if student_calibrated_range
          if question_range_cal_student
            question_range_cal_student.calibrated_students += 1
            question_range_cal_student.calibrated_student_answers += q_answers
            question_range_cal_student.calibrated_student_points += q_earned_points
            # question_range_cal_student.update_attributes(params[:ifa_question_performance])
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
        student_baseline_score = self.user.ifa_user_baseline_scores.for_subject(self.act_subject).for_standard(mstr).first.score rescue nil
        student_baseline_range = ActScoreRange.for_standard(mstr).for_subject_sms(self.act_subject, student_baseline_score).first rescue nil
        question_range_base_student = question.ifa_question_performances.for_range(student_baseline_range).first rescue nil
        if student_baseline_range
          if question_range_base_student
            question_range_base_student.baseline_students += 1
            question_range_base_student.baseline_answers += q_answers
            question_range_base_student.baseline_points += q_earned_points
            # question_range_base_student.update_attributes(params[:ifa_question_performance])
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
end
