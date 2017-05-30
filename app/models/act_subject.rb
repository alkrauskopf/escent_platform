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
  has_many :ifa_classroom_options
  has_many :ifa_question_logs
  has_many :blogs
  has_many :ifa_user_baseline_scores
  has_many :student_subject_demographics
  has_many :co_csap_ranges
  has_many :subject_areas
  has_many :ifa_plans
  has_many :classrooms, :through => :subject_areas
        
  scope :no_na, {:conditions => ["name != ?", "-na-"]}


  def self.all_subjects
    where('id != ?', 99).order('name ASC')
  end

  def self.ew
    where('name = ?', 'English & Writing').first
  end

  def self.math
    where('name = ?', 'Mathematics').first
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

end

