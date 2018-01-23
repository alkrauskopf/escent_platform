class ActSubject < ActiveRecord::Base

  include PublicPersona
  
  has_many :act_benches, :dependent => :destroy
  has_many :act_rel_readings
  has_many :contents
  has_many :classrooms
  has_many :act_assessments
  has_many :act_questions
  has_many :act_submissions
  has_many :act_snapshots
  has_many :act_score_ranges
  has_many :act_standards
  has_many :co_standards   
  has_many :co_grade_levels  
  has_many :ifa_dashboards
  has_many :ifa_plan_metrics
  has_many :ifa_classroom_options
  has_many :ifa_question_logs
  has_many :blogs
  has_many :ifa_user_baseline_scores
  has_many :student_subject_demographics
  has_many :co_csap_ranges
  has_many :subject_areas
  has_many :ifa_plans
  has_many :act_strategies
  has_many :act_strategy_logs
#  has_many :classrooms, :through => :subject_areas
        
  scope :no_na, {:conditions => ["name != ?", "-na-"]}


  def self.all_subjects
    where('is_enabled').order('posit ASC')
  end

  def self.ew
    where('name = ?', 'English & Writing').first
  end

  def self.math
    where('name = ?', 'Mathematics').first
  end

  def self.math_number
    where('name = ?', 'Numbers, Algebra, Functions').first
  end

  def self.math_geo_stat
    where('name = ?', 'Geometry, Measurement, Statistics').first
  end

  def self.rl
    where('name = ?', 'Reading, Literature').first
  end

  def self.science
    where('name = ?', 'Science').first
  end

  def self.ss
    where('name = ?', 'Social Studies').first
  end

  def self.na
    where('name = ?', '-na-').first
  end

  def plannable?
    self.is_plannable
  end

  def self.plannable
    where('is_plannable')
  end

  def self.active_plannable
    where('is_enabled && is_plannable').order('posit ASC')
  end

  def active?
    self.is_enabled
  end

  def self.active
    where('is_enabled').order('posit ASC')
  end

  def available_questions(user, level, strand)
    if user.nil? && level.nil? && strand.nil?
      self.act_questions.enabled
    elsif level.nil? && strand.nil?
      self.act_questions.for_user(user).enabled
    elsif user.nil? && strand.nil?
      self.act_questions.for_level(level).enabled
    elsif user.nil? && level.nil?
      self.act_questions.for_strand(strand).enabled
    elsif !level.nil? && !user.nil? && strand.nil?
      self.act_questions.for_user(user).for_level(level).enabled
    elsif !level.nil? && !strand.nil? && user.nil?
      self.act_questions.for_level(level).for_strand(strand).enabled
    elsif !user.nil? && !strand.nil? && level.nil?
      self.act_questions.for_user(user).for_strand(strand).enabled
    else
      self.act_questions.for_user(user).for_level(level).for_strand(strand).enabled
    end
  end

  def active_strategies
    self.act_strategies.active
  end

  def default_strategy
    self.act_strategies.default
  end

end

