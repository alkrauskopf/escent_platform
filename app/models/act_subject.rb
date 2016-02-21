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
        
  scope :no_na, {:conditions => ["name != ?", "-na-"]}
  
end

