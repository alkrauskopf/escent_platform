class ActAssessment < ActiveRecord::Base

  include PublicPersona

  has_many :act_assessment_act_questions, :dependent => :destroy
  has_many :act_questions, :through => :act_assessment_act_questions, :order => "position ASC"
  has_many :act_assessment_classrooms, :dependent => :destroy
  has_many :classrooms, :through => :act_assessment_classrooms, :order => "position"
  has_many :act_assessment_act_standards, :dependent => :destroy
  has_many :act_standards, :through => :act_assessment_act_standards, :order => "pos"
  has_many :act_answers
  has_many :act_submissions
  has_many :act_assessment_score_ranges
  has_many :ifa_question_logs
  
  belongs_to :act_subject
  belongs_to :user
  belongs_to :organization
  belongs_to :lower_level, :class_name => 'ActScoreRange', :foreign_key => 'lower_level_id'
  belongs_to :upper_level, :class_name => 'ActScoreRange', :foreign_key => 'upper_level_id'

  validates_presence_of :act_subject_id
  validates_presence_of :name


  scope :calibrated, :conditions => { :is_calibrated => true }
  scope :unlocked, :conditions => { :is_locked => false }
  scope :lock, :conditions => { :is_locked => true }, :order => 'updated_at DESC'
  scope :for_subject, lambda{| subject| {:conditions => ["act_subject_id = ?", subject.id]}}
  scope :active, :conditions => { :is_active => true }, :order => 'updated_at DESC'
  scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}}
  scope :by_date, :order => 'updated_at DESC'


  def active?
    self.is_active
  end

  def enableable?
    !self.act_questions.active.empty?
    true
  end

  def locked?
    self.is_locked
  end

  def destroyable?
    !self.active?
  end

  def calibrated?
    self.is_calibrated
  end

  def untagged?
    self.lower_level.nil? || self.upper_level.nil? || self.strands.empty?
  end

  def self.untagged(assessments)
    assessments.select{|a| a.untagged?}
  end

  def self.empties
    ActAssessment.all.select{|a| a.act_assessment_act_questions.empty?}
  end

  def properly_tagged?
    !self.lower_level.nil? && !self.upper_level.nil? && !self.strands.empty?
  end

  def self.properly_tagged(assessments)
    assessments.select{|a| a.properly_tagged?}
  end

  def questions_calibrated?
    self.act_questions.not_calibrated.empty?
  end

  def all_questions
 #   self.act_assessment_act_questions.by_position.collect{|aq| aq.act_question}
    self.act_questions.uniq
  end

  def active_questions
    self.act_questions.uniq.select{|q| q.active?}
  end

  def mastery_levels
    self.act_questions.collect{|q| q.mastery_level}.compact.uniq.sort_by{|r| r.lower_score}
  end

  def strands
    self.act_standards
  end

  def question_strands
    self.act_questions.collect{|q| q.strand}.compact.uniq.sort_by{|s| s.pos}
  end

  def strand_string
    self.strands.empty? ?  'None' : self.strands.collect{|s| s.abbrev}.join(', ')
  end

  def self.creators
    all.collect{|a| a.user}.compact.uniq.sort_by{|u| u.last_name}
  end

  def min_question_level
    self.mastery_levels.first
  end

  def max_question_level
    self.mastery_levels.last
  end

  def question_joins(question)
    self.act_assessment_act_questions.for_question(question)
  end

  def reconstitute
    upper_score = self.max_question_level.nil? ? 0 : self.max_question_level.upper_score
    lower_score = self.min_question_level.nil? ? 0 : self.min_question_level.lower_score
    self.update_attributes(:lower_level_id => (self.min_question_level.nil? ? nil : self.min_question_level.id),
                                          :upper_level_id => (self.max_question_level.nil? ? nil : self.max_question_level.id),
                                          :min_score => lower_score, :max_score => upper_score, :is_calibrated => self.questions_calibrated?,
                                          :original_assessment_id => (self.original_assessment_id.nil? ? self.id : self.original_assessment_id))
    if self.strands != self.question_strands
      # Add differences
      (self.question_strands - self.strands).each do |strand|
        self.act_standards << strand
      end
      # Remove differences
      (self.strands - self.question_strands).each do |strand|
        self.act_assessment_act_standards.for_strand(strand).destroy_all
      end
    end
  end


  ################

  def question_pool_for(user)
    question_pool = self.act_subject.act_questions.active rescue []
    filter = user.ifa_user_option rescue nil
    if filter
      if filter.is_calibrated && filter.is_user_filtered
        question_pool = question_pool.select{|q| q.is_calibrated AND q.user_id == user.id} rescue []
      elsif filter.is_calibrated && !filter.is_user_filtered
        question_pool = question_pool.select{|q| q.is_calibrated} rescue []
      elsif !filter.is_calibrated && filter.is_user_filtered
        question_pool = question_pool.select{|q| q.user_id == user.id} rescue []
      end 
      if filter.act_rel_reading
        question_pool = question_pool.select{|q| q.act_rel_reading_id == filter.act_rel_reading_id} rescue []
      end
      if filter.act_score_range
        question_pool = question_pool.select{|q| q.act_score_ranges.include?(filter.act_score_range)} rescue []
      end
      if filter.act_standard
        question_pool = question_pool.select{|q| q.act_standards.include?(filter.act_standard)} rescue []
      end
    end
    question_pool.sort!{|a,b| b.updated_at <=> a.updated_at}
  end

  def position_forx(question)
    self.act_assessment_act_questions.select{|q| q.act_question_id == question.id}.first.position rescue ""
  end
  def position_for(question)
    self.act_assessment_act_questions.for_question(question).first.position.to_s rescue ""
  end

  def sequence_questions
    questions = self.act_assessment_act_questions.sort_by{|a|a.position}
    questions.each_with_index do |quest,idx|
      quest.update_attributes(:position=>idx+1)
    end
  end

 def reposition_question(question, new_position)
  ass_quest = self.act_assessment_act_questions.for_question(question).first 
  unless ass_quest.nil?
    old_position = ass_quest.position
    ass_quest.update_attributes(:position=>new_position)
    self.act_assessment_act_questions.each do |quest|
     unless quest == ass_quest
        if (quest.position > old_position) && (quest.position <= new_position)
          then quest.update_attributes(:position=>quest.position-1)       
        elsif (quest.position < old_position) && (quest.position >= new_position)
          then quest.update_attributes(:position=>quest.position+1)
        end
      end
    end
  self.sequence_questions
  end
 end


  def lower_score(std)
    #   range = self.act_assessment_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
    range = self.act_assessment_score_ranges.for_standard(std).first rescue nil
    score = range.nil? ? 0 : range.lower_score
  end

  def upper_score(std)
    #  range = self.act_assessment_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
    range = self.act_assessment_score_ranges.for_standard(std).first rescue nil
    score = range.nil? ? 0 : range.upper_score
  end

  def score_range(std)
    range = self.act_assessment_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
    if range
      score = range.lower_score.to_s + " - " + range.upper_score.to_s
    else
      score = "No Level"
    end
  end
  def score_range_sat(std)
    range = self.act_assessment_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
    if range
      score = range.lower_score.to_s + " - " + range.upper_score.to_s
    else
      score = "No Level"
    end
  end

  def max_question_score(std)
#    self.act_questions.collect{|q| q.upper_score(std.to_s)}.max 
    scores = []
    self.act_questions.each do |q|
    scores << q.upper_score(std)
    end
    unless scores.empty?
      score = scores.max
    else
    score = 0
    end
  end

  def min_question_score(std)
   scores = []
    self.act_questions.each do |q|
    scores << q.lower_score(std)
    end
    unless scores.empty?
      score = scores.min
    else
      score = 0
    end
  end

  def set_min_and_max
    masters = ActMaster.all
    masters.each do |mstr|
      min_score = self.min_question_score(mstr)
      max_score = self.max_question_score(mstr)
     ActAssessmentScoreRange.destroy_all(["act_assessment_id = ? AND act_master_id = ?", self.id, mstr.id])rescue nil
     unless min_score == 0 && max_score == 0
          range = ActAssessmentScoreRange.new
          range.upper_score = max_score
          range.lower_score = min_score
          range.act_assessment_id = self.id
          range.act_master_id = mstr.id
          range.save 
      end
    end
  end

  def calibrate
    calibrations = self.act_questions.collect{|q| q.is_calibrated }
    if (calibrations.empty? ) || (calibrations.include? false)
       self.update_attributes(:is_calibrated => false)
    else
      self.update_attributes(:is_calibrated => true)
    end
  end

  def sequence_score_for(std, filter)
   sequence_scores = self.act_questions.collect{|q| q.sequence_score_for(std, filter)}.compact rescue []
   sum_of_scores = sequence_scores.sum
   seq_score = sequence_scores.size > 0 ? (sum_of_scores.to_f/ sequence_scores.size.to_f).round : nil
  end 

  def alignment_score_for(std, filter)
   alignment_scores = self.act_questions.collect{|q| q.alignment_score_for(std, filter)}.compact rescue []
   sum_of_scores = alignment_scores.sum
   align_score = alignment_scores.size > 0 ? (sum_of_scores.to_f/ alignment_scores.size.to_f).round : nil
  end



  def check_lock
    locks = self.act_questions.collect{|q| q.is_locked }
    if (locks.empty? ) || (locks.include? false)
       self.update_attributes(:is_locked => false)
    end
  end

end
