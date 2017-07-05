class ActSubmission < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_assessment
  belongs_to :user
  belongs_to :classroom
  belongs_to :organization
  belongs_to :act_subject
  belongs_to :act_master
  belongs_to :teacher, :class_name => 'User', :foreign_key => "teacher_id"
  has_one :subject, :through => :act_assessment, :source => 'act_subject'
  
  has_many :act_answers, :dependent => :destroy
  has_many :act_submission_scores, :dependent => :destroy
  has_many :ifa_student_levels, :dependent => :destroy
  has_many :ifa_question_logs, :dependent => :destroy
  
  validates_presence_of :teacher_id, :message => 'No Teacher Identified - '
  validates_presence_of :act_assessment_id, :message => 'No Assessment Identified - '
  validates_presence_of :user_id, :message => 'No User Identified - '
  validates_presence_of :classroom_id, :message => 'No Classroom Identified - '
  validates_presence_of :act_subject_id, :message => 'No Assessment Subject Identified - '
  validates_presence_of :organization_id, :message => 'No Organization Identified - '
  validates_numericality_of :duration, :greater_than => 0, :message => 'No Duration - '

  scope :final, :conditions => { :is_final => true }, :order => 'created_at DESC'
  scope :not_final, :conditions => { :is_final => false }
  scope :auto_finalized, :conditions => { :is_auto_finalized => true }
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  scope :not_user_dashboarded, :conditions => {:is_user_dashboarded => false} rescue []
  scope :not_classroom_dashboarded, :conditions => { :is_classroom_dashboarded => false } rescue []
  scope :not_org_dashboarded, :conditions => {:is_org_dashboarded => false} rescue []
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

  def calibrated?
    self.act_assessment.nil? ? false : self.act_assessment.calibrated?
  end

  def self.month_periods_final
    where('is_final').order('created_at DESC').map{|s| s.created_at.end_of_month}.uniq
  end
  def self.month_periods
    order('created_at DESC').map{|s| s.created_at.end_of_month}.uniq
  end
  def self.classroom_list_final
    where('is_final').map{|s| s.classroom}.compact.uniq.sort_by{|c| c.course_name}
  end
  def self.organization_list_final
    where('is_final').map{|s| s.organization}.compact.uniq.sort_by{|o| o.short_name}
  end
  def self.user_list_final
    where('is_final').map{|s| s.user}.compact.uniq.sort_by{|u| u.last_name}
  end

  def self.pending(options={})
    if options[:teacher]
      where('teacher_id = ? && is_final = ?', options[:teacher].id, false).order('created_at DESC')
    else
      where('is_final = ?', false).order('created_at DESC')
    end
  end

  def self.final(options={})
    if options[:teacher]
      where('teacher_id = ? && is_final', options[:teacher].id).order('created_at DESC')
    else
      where('is_final').order('created_at DESC')
    end
  end

  #    Submission Analysis Stats

  def self.submission_stats(submission_list)
    submission_stats = []
    submission_stats = [submission_list.select{|s| s.is_final}.size,
                        submission_list.select{|s| s.calibrated?}.size,
                        submission_list.select{|s| s.is_user_dashboarded}.size,
                        submission_list.select{|s| s.is_classroom_dashboarded}.size,
                        submission_list.select{|s| s.is_org_dashboarded}.size,
                        submission_list.map{|s| s.tot_points}.sum,
                        submission_list.map{|s| s.tot_choices}.sum,
                        submission_list.map{|s| s.cal_points}.sum,
                        submission_list.map{|s| s.cal_choices}.sum,
                        submission_list.map{|s| s.duration}.sum,
                        submission_list.map{|s| s.teacher}.compact.uniq,
                        submission_list.select{|s| !s.is_final}.size,
                        submission_list.map{|s| (s.is_final ? s.tot_points : 0)}.sum,
                        submission_list.map{|s| (s.is_final ? s.tot_choices : 0)}.sum,
                        submission_list.map{|s| (s.lower_score_bound.nil? ? 0 : s.lower_score_bound)}.min,
                        submission_list.map{|s| (s.upper_score_bound.nil? ? 99999 : s.upper_score_bound)}.max
                        ]
  end

  def dashboarded?(entity_class)
    entity_class == 'User' ? self.is_user_dashboarded : (entity_class == 'Classroom' ? self.is_classroom_dashboarded : self.is_org_dashboarded)
  end

  def destroy_it
    if self.dashboarded?('User')
      db = self.user.ifa_dashboards.for_subject_period(self.act_subject, self.created_at).first rescue nil
      if !db.nil?
        db.redash_needed
      end
    end
    if self.dashboarded?('Classroom')
      db = self.classroom.ifa_dashboards.for_subject_period(self.act_subject, self.created_at).first rescue nil
      if !db.nil?
        db.redash_needed
      end
    end
    if self.dashboarded?('Organization')
      db = self.organization.ifa_dashboards.for_subject_period(self.act_subject, self.created_at).first rescue nil
      if !db.nil?
        db.redash_needed
      end
    end
    self.destroy
  end

  def subject
    self.act_subject
  end

  def upper_bound_score
    self.act_assessment.nil? ? 0 : self.act_assessment.upper_level.upper_score
  end

  def lower_bound_score
    self.act_assessment.nil? ? 0 : self.act_assessment.lower_level.lower_score
  end

  def assessment_standard
    self.act_assessment.nil? ? nil : (self.act_assessment.act_master.nil? ? nil : self.act_assessment.act_master)
  end

  def standard_abbrev
    self.act_master.nil? ? '' : self.act_master.abbrev
  end

  def assessment_name
    self.act_assessment.nil? ? 'Removed Assessment' : self.act_assessment.name
  end

  def strand_string
    self.act_assessment.nil? ? 'Unknown Strands' : self.act_assessment.strand_string
  end

  def self.for_assessment(assessment)
    if !assessment.nil?
      where('act_assessment_id = ?', assessment.id).order('created_at DESC')
    end
  end

  def self.final_for_subject_window(subject, begin_date, end_date)
    where('act_subject_id = ? AND date_finalized >= ? AND date_finalized <= ? AND is_final', subject.id, begin_date, end_date)
  end

  def self.final_for_subject_since(subject, begin_date)
    where('act_subject_id = ? AND date_finalized >= ? AND is_final', subject.id, begin_date)
  end

  def mc_answers_for_question(question)
    self.act_answers.answer_choices(question)
  end

  def short_answer_for_question(question)
    self.act_answers.short_answer(question)
  end

  def correct_answers(options = {})
    if options[:level] && options[:strand]
      answers = self.act_answers.correct.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
    elsif options[:level]
      answers = self.act_answers.correct.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level])}
    elsif options[:strand]
      answers = self.act_answers.correct.selected.select{|a| !a.act_question.nil? && a.act_question.of_strand?(options[:strand])}
    else
      answers = self.act_answers.correct.selected
    end
    answers
  end

  def answer_points(options = {})
    if options[:level] && options[:strand]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
    elsif options[:level]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level])}
    elsif options[:strand]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_strand?(options[:strand])}
    else
      answers = self.act_answers.selected
    end
    answers.sum(&:points)
  end

  def answers_selected(options = {})
    if options[:level] && options[:strand]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
    elsif options[:level]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level])}
    elsif options[:strand]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_strand?(options[:strand])}
    else
      answers = self.act_answers.selected
    end
    answers.size
  end

  def incorrect_answers(options = {})
    if options[:level] && options[:strand]
      answers = self.act_answers.incorrect.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
    elsif options[:level]
      answers = self.act_answers.incorrect.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level])}
    elsif options[:strand]
      answers = self.act_answers.incorrect.selected.select{|a| !a.act_question.nil? && a.act_question.of_strand?(options[:strand])}
    else
      answers = self.act_answers.incorrect.selected
    end
    answers
  end

  def total_answers(options = {})
    if options[:level] && options[:strand]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
    elsif options[:level]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_mastery_level?(options[:level])}
    elsif options[:strand]
      answers = self.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.of_strand?(options[:strand])}
    else
      answers = self.act_answers.selected
    end
    answers
  end

  def self.correct_subject_answers(subject,entity, options = {})
    if options[:since]
      correct_answers = entity.act_submissions.final.for_subject(subject).since(options[:since]).collect{|s| s.correct_answers(:level, :strand)}.flatten
    else
      correct_answers = entity.act_submissions.final.for_subject(subject).collect{|s| s.correct_answers(:level, :strand)}.flatten
    end
    correct_answers
  end

  def self.incorrect_subject_answers(subject,entity, options = {})
    if options[:since]
      incorrect_answers = entity.act_submissions.final.for_subject(subject).since(options[:since]).collect{|s| s.incorrect_answers(:level, :strand)}.flatten
    else
      incorrect_answers = entity.act_submissions.final.for_subject(subject).collect{|s| s.incorrect_answers(:level, :strand)}.flatten
    end
    incorrect_answers
  end

  def self.total_subject_answers(subject,entity, options = {})
    if options[:since]
      total_answers = entity.act_submissions.final.for_subject(subject).since(options[:since]).collect{|s| s.total_answers(:level, :strand)}.flatten
    else
      total_answers = entity.act_submissions.final.for_subject(subject).collect{|s| s.total_answers(:level, :strand)}.flatten
    end
    total_answers
  end

  def score_it!(standard)
    self.act_submission_scores.destroy_all
    submission_score = ActSubmissionScore.new(:act_master_id => standard.id)
    submission_score.est_sms = self.standard_scoring_rule
    submission_score.final_sms = self.standard_scoring_rule
    self.act_submission_scores << submission_score
  end

  def score_for(standard)
    self.act_submission_scores.for_standard(standard).empty? ? nil :self.act_submission_scores.for_standard(standard).first
  end

  def finalize_new(auto, reviewer_id, standard)
    finalized = false
    self.reviewer_id = reviewer_id
    self.is_auto_finalized = auto
    self.is_final = true
    self.is_user_dashboarded = false
    self.is_org_dashboarded = false
    self.is_classroom_dashboarded = false
    self.date_finalized = Time.now
    self.upper_score_bound = self.upper_bound_score
    self.lower_score_bound = self.lower_bound_score
    self.tot_points = self.total_points
    self.tot_choices = self.total_choices
    self.tot_points = self.total_points
    self.tot_choices = self.total_choices
    if self.score_for(standard).nil?
      submission_score = ActSubmissionScore.new(:act_master_id => standard.id)
      submission_score.est_sms = self.standard_scoring_rule
      submission_score.final_sms = self.standard_scoring_rule
      self.act_submission_scores << submission_score
    else
      self.score_for(standard).update_attributes(:final_sms => self.standard_scoring_rule)
    end
    if self.save
      # Update User Dashboard Only
      self.auto_ifa_dashboard_update_new(self.user, standard)
      # Only Automatically Update First Classroom & Org Dashboard of Period
      #
      # Now, Try updating always
      # if !self.period_dashboard?(self.classroom)
      # Don't Classroom dashboard Submissions with incompatible subjects
      if self.act_subject_id == self.classroom.act_subject_id
        self.auto_ifa_dashboard_update_new(self.classroom, standard)
      end
      # end
      # if !self.period_dashboard?(self.organization)
        self.auto_ifa_dashboard_update_new(self.organization, standard)
      # end
      finalized = true
    end
    finalized
  end

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

  def set_dashboardable(entity,on_off)
    if entity.class.to_s == "User"
      self.update_attributes(:is_user_dashboarded => on_off)
    elsif entity.class.to_s == "Classroom"
      self.update_attributes(:is_classroom_dashboarded => on_off)
    elsif entity.class.to_s == "Organization"
      self.update_attributes(:is_org_dashboarded => on_off)
    end
  end

  def auto_ifa_dashboard_update_new(entity, standard)
    if entity.class.to_s == "User"
      if self.is_user_dashboarded
        already_dashboarded = true
      else
        already_dashboarded = false
        entity_dashboard = self.user.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first rescue nil
        dashboardable_id = self.user_id
        self.set_dashboardable(entity, true)
      end
    elsif entity.class.to_s == "Classroom"
      if self.is_classroom_dashboarded
        already_dashboarded = true
      else
        already_dashboarded = false
        entity_dashboard = self.classroom.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first rescue nil
        dashboardable_id = self.classroom_id
        self.set_dashboardable(entity, true)
      end
    elsif entity.class.to_s == "Organization"
      if self.is_org_dashboarded
        already_dashboarded = true
      else
        already_dashboarded = false
        entity_dashboard = self.organization.ifa_dashboards.for_subject(self.act_subject).for_period(self.created_at.to_date.at_end_of_month).first rescue nil
        dashboardable_id = self.organization_id
        self.set_dashboardable(entity, true)
      end
    end
    if !already_dashboarded
      if entity_dashboard.nil?
        entity_dashboard = IfaDashboard.new
        entity_dashboard.ifa_dashboardable_id = dashboardable_id
        entity_dashboard.ifa_dashboardable_type = entity.class.to_s
        entity_dashboard.period_end = self.created_at.to_date.at_end_of_month
        entity_dashboard.organization_id = self.classroom.organization_id
        entity_dashboard.act_subject_id = self.act_subject_id
        entity_dashboard.assessments_taken = 1
        entity_dashboard.finalized_assessments = 1
        entity_dashboard.calibrated_assessments = self.act_assessment.is_calibrated ? 1: 0
        entity_dashboard.finalized_answers = self.tot_choices rescue 0
        entity_dashboard.calibrated_answers = self.cal_choices rescue 0
        entity_dashboard.cal_submission_answers = self.act_assessment.is_calibrated ? self.cal_choices : 0
        entity_dashboard.finalized_duration = self.duration
        entity_dashboard.calibrated_duration = self.act_assessment.is_calibrated ?  self.duration : 0
        entity_dashboard.fin_points = self.tot_points rescue 0.0
        entity_dashboard.cal_points = self.cal_points rescue 0.0
        entity_dashboard.cal_submission_points = self.act_assessment.is_calibrated ? self.cal_points : 0.0
        entity_dashboard.save
      else
        entity_dashboard.assessments_taken += 1
        entity_dashboard.finalized_assessments += 1
        entity_dashboard.finalized_answers += self.tot_choices
        entity_dashboard.calibrated_answers += self.cal_choices
        entity_dashboard.finalized_duration += self.duration
        entity_dashboard.fin_points += self.tot_points
        entity_dashboard.cal_points += self.cal_points
        if self.act_assessment.is_calibrated
          entity_dashboard.calibrated_assessments += 1
          entity_dashboard.calibrated_duration += self.duration
          entity_dashboard.cal_submission_points += self.cal_points
          entity_dashboard.cal_submission_answers += self.tot_points
        end
        entity_dashboard.save
      end
      #  Standard is now passed parameter and elimiate Question log
      self.act_answers.selected.each do |answer|
        if !answer.mastery_level.nil? && !answer.strand.nil?
          q_strand = answer.strand
          q_range = answer.mastery_level
          dashboard_cell = entity_dashboard.ifa_dashboard_cells.with_range_id(q_range.id).with_strand_id(q_strand.id).first
          unless dashboard_cell
            dashboard_cell = IfaDashboardCell.new
            dashboard_cell.act_master_id = standard.id
            dashboard_cell.act_score_range_id = q_range.id
            dashboard_cell.act_standard_id = q_strand.id
            dashboard_cell.finalized_answers = 1
            dashboard_cell.calibrated_answers = answer.act_question.is_calibrated ? 1 : 0
            dashboard_cell.fin_points = answer.points
            dashboard_cell.cal_points = answer.act_question.is_calibrated ? answer.points : 0.0
            entity_dashboard.ifa_dashboard_cells << dashboard_cell
          else
            dashboard_cell.finalized_answers += 1
            dashboard_cell.calibrated_answers += answer.act_question.is_calibrated ? 1 : 0
            dashboard_cell.fin_points += answer.points
            dashboard_cell.cal_points += answer.act_question.is_calibrated ? answer.points : 0.0
            dashboard_cell.save
          end
        end
      end  # end of answers

      dashboard_sms = entity_dashboard.ifa_dashboard_sms_scores.for_standard(standard).first rescue nil
      #     up_to_date = entity_dashboard.period_end
      #    up_to_date = Date.today
      #    since_date = (up_to_date - self.organization.ifa_org_option.sms_calc_cycle.days).to_date rescue Date.today.at_end_of_month
      #   h_threshold = self.organization.ifa_org_option.sms_h_threshold rescue 0.75
      if dashboard_sms.nil?
        dashboard_sms = IfaDashboardSmsScore.new
        dashboard_sms.act_master_id = standard.id
        dashboard_sms.ifa_dashboard_id = entity_dashboard.id
      end
      dashboard_sms.score_range_min = entity_dashboard.level_range(standard).first.lower_score rescue 0
      dashboard_sms.score_range_max = entity_dashboard.level_range(standard).last.upper_score rescue 0
      dashboard_sms.standard_score = entity_dashboard.calculated_standard_score(standard, :calibrated => false)
      dashboard_sms.standard_score_cal = entity_dashboard.calculated_standard_score(standard, :calibrated => true)
      dashboard_sms.sms_finalized = standard.sms_for_dashboard(entity_dashboard, :calibrated => false)
      dashboard_sms.sms_calibrated = standard.sms_for_dashboard(entity_dashboard, :calibrated => true)
      dashboard_sms.baseline_score = standard.base_score(entity, self.act_subject)
      entity_dashboard.ifa_dashboard_sms_scores << dashboard_sms
      dashboard_sms.save
    end # Already Dashboarded Condition
  end


  def dashboard_it_new(dashboard_class)
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

  def standard_scoring_rule
    score_pct = (self.tot_choices.nil? || (self.tot_choices == 0) || self.tot_points.nil?) ? 0.0 : (self.tot_points/self.tot_choices.to_f)
    score = 0
    if !self.act_assessment.nil? && !self.act_assessment.lower_level.nil? && !self.act_assessment.upper_level.nil?
      min_score = self.act_assessment.lower_level.lower_score
      max_score = self.act_assessment.upper_level.upper_score
        delta = (max_score - min_score).to_f
        score = min_score + (delta * score_pct).to_i
    end
    score
  end

  def total_points
    self.act_answers.map{|a|a.points}.sum rescue 0.0
  end
  def total_cal_points
    self.act_answers.select{|a| a.is_calibrated}.map{|a|a.points}.sum rescue 0.0
  end
  def total_choices
    self.act_answers.selected.size rescue 0
  end
  def total_cal_choices
    self.act_answers.select{|a| a.is_calibrated}.map{|a|a.selected}.sum rescue 0
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

  #####   Original Finalize & Dashboarding methods

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
    self.cal_points = self.total_cal_points
    self.tot_choices = self.total_cal_choices
    self.act_submission_scores.each do |std|
      fin_sms = self.is_auto_finalized ? std.est_sms : self.standard_assessment_score(std.act_master)
      std.update_attributes(:final_sms => fin_sms)
    end
    # if self.update_attributes params[:act_submission]
    if self.save
      # Update User Dashboard Only
      self.auto_ifa_dashboard_update(self.user)
      # Only Automatically Update First Classroom & Org Dashboard of Period
      #
      # Now, Try updating always
      if !self.period_dashboard?(self.classroom)
        self.auto_ifa_dashboard_update(self.classroom)
      end
      if !self.period_dashboard?(self.organization)
        self.auto_ifa_dashboard_update(self.organization)
      end
      finalized = true
    end
    finalized
  end


  def dashboard_it(dashboard_class)
    self.auto_ifa_dashboard_update(dashboard_class)
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
        entity_dashboard.finalized_answers = self.tot_choices rescue 0
        entity_dashboard.calibrated_answers = self.cal_choices rescue 0
        entity_dashboard.cal_submission_answers = self.act_assessment.is_calibrated ? self.cal_choices : 0
        entity_dashboard.finalized_duration = self.duration
        entity_dashboard.calibrated_duration = self.act_assessment.is_calibrated ?  self.duration : 0
        entity_dashboard.fin_points = self.tot_points rescue 0.0
        entity_dashboard.cal_points = self.cal_points rescue 0.0
        entity_dashboard.cal_submission_points = self.act_assessment.is_calibrated ? self.cal_points : 0.0
        entity_dashboard.save
      else
        entity_dashboard.assessments_taken += 1
        entity_dashboard.finalized_assessments += 1
        entity_dashboard.finalized_answers += self.tot_choices
        entity_dashboard.calibrated_answers += self.cal_choices
        entity_dashboard.finalized_duration += self.duration
        entity_dashboard.fin_points += self.tot_points
        entity_dashboard.cal_points += self.cal_points
        if self.act_assessment.is_calibrated
          entity_dashboard.calibrated_assessments += 1
          entity_dashboard.calibrated_duration += self.duration
          entity_dashboard.cal_submission_points += self.cal_points
          entity_dashboard.cal_submission_answers += self.cal_choices
        end
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
#              dashboard_cell.finalized_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, true)
            entity_dashboard.ifa_dashboard_cells << dashboard_cell
          else
            dashboard_cell.finalized_answers += log.choices
            dashboard_cell.calibrated_answers += log.is_calibrated ? log.choices : 0
            dashboard_cell.fin_points += log.earned_points
            dashboard_cell.cal_points += log.is_calibrated ? log.earned_points : 0.0
#              dashboard_cell.finalized_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, false)
#              dashboard_cell.calibrated_hover = target_hovers(entity, self.act_subject, q_range, q_strand, entity_dashboard_xx.period_end.beginning_of_month, 75, true)
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
#   JUst One Standard Now
#     self.organization.ifa_org_option.act_masters.each do |mstr|
      mstr = ActMaster.default
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

      #   end  # End Master Loop for Question Performance
    end
  end

end
