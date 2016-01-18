class ActAssessment < ActiveRecord::Base

  include PublicPersona

  has_many :act_assessment_act_questions, :dependent => :destroy
  has_many :act_questions, :through => :act_assessment_act_questions, :order => "position"  
  has_many :act_assessment_classrooms, :dependent => :destroy
  has_many :classrooms, :through => :act_assessment_classrooms, :order => "position"  
  has_many :act_answers
  has_many :act_submissions
  has_many :act_assessment_score_ranges
  has_many :ifa_question_logs
  
  belongs_to :act_subject
  belongs_to :user
  belongs_to :organization
  
  validates_presence_of :act_subject_id
  validates_presence_of :name


  named_scope :calibrated, :conditions => { :is_calibrated => true }
  named_scope :unlocked, :conditions => { :is_locked => false }
  named_scope :locked, :conditions => { :is_locked => true }  
  named_scope :for_subject, lambda{| subject| {:conditions => ["act_subject_id = ?", subject.id]}} 
  named_scope :active, :conditions => { :is_active => true }
  named_scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}} 
  named_scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}} 

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

  def position_for(question)
    self.act_assessment_act_questions.select{|q| q.act_question_id == question.id}.first.position rescue ""
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
    masters = ActMaster.find(:all)
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
