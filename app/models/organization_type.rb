class OrganizationType < ActiveRecord::Base
 
  acts_as_tree

  has_many :organizations
  has_many :itl_summaries
  has_many :grade_levels
  has_many  :elt_cases, :through => :organizations

  scope :schools,   :conditions => ["has_size"]
  scope :k12,   :conditions => ["is_k12"]
  
  validates_presence_of :name

 
 def school?
   self.has_size  
 end
 
 def k12?
   self.is_k12  
 end

  def self.highschool
    self.where('name = ?', 'High School').first
  end

   
  def self.affiliate
    @affliate ||= self.find_by_name("Affiliate")
  end

  def itl_summaries_for_month_subject(subj, month)
       if subj
         # ItlSummary.find(:all, :conditions => ["organization_type_id = ? AND subject_area_id = ? AND yr_mnth_of = ? ", self.id, subj.id, month.beginning_of_month])
        self.itl_summaries.for_subject(subj).for_month(month.beginning_of_month)
       else
         # ItlSummary.find(:all, :conditions => ["organization_type_id = ? AND yr_mnth_of = ? ", self.id,  month.beginning_of_month])
         self.itl_summaries.for_month(month.beginning_of_month)
       end
  end

  def itl_summaries_since_date_subject(subj, month)
       if subj
         # ItlSummary.find(:all, :conditions => ["organization_type_id = ? AND subject_area_id = ? AND yr_mnth_of >= ?", self.id, subj.id, month.beginning_of_month])
         self.itl_summaries.for_subject(subj).since_date(month.beginning_of_month)
       else
         # ItlSummary.find(:all, :conditions => ["organization_type_id = ? AND yr_mnth_of >= ? ", self.id, month.beginning_of_month])
         self.itl_summaries.since_date(month.beginning_of_month)
       end
  end

  def itl_summaries_between_dates_subject(subj, month1, month2)
       if subj
         # ItlSummary.find(:all, :conditions => ["organization_type_id = ? AND subject_area_id = ?  AND yr_mnth_of >= ? AND yr_mnth_of <= ?", self.id, subj.id, month1.beginning_of_month, month2.end_of_month])
         self.itl_summaries.for_subject(subj).between_dates(month1.beginning_of_month, month2.end_of_month)
       else
         # ItlSummary.find(:all, :conditions => ["organization_type_id = ? AND yr_mnth_of >= ? AND yr_mnth_of <= ?", self.id, month1.beginning_of_month, month2.end_of_month])
         self.itl_summaries.between_dates(month1.beginning_of_month, month2.end_of_month)
       end
  end

  def itl_summaries_between_dates_subject_belt(subj, month1, month2, belt)
    itl_summaries_between_dates_subject(subj, month1, month2).select{|s| !s.itl_belt_rank.nil? && s.itl_belt_rank.rank_score >= belt.rank_score}
  end
   
  def itl_subjects
    self.organizations.collect{|o| o.subjects_with_tlt_sessions}.flatten.uniq
  end

  def itl_organizations
    self.organizations.select{|o| !o.tlt_sessions.empty?}
  end

  def minutes_in_subject(subject)
    self.itl_organizations.collect{|o| o.minutes_in_subject(subject)}.sum 
  end

  def classroom_count(subject)
    self.itl_organizations.collect{|o| o.classroom_count(subject)}.sum
  end

  def period_count(subject)
    self.itl_organizations.collect{|o| o.period_count(subject)}.sum 
  end

  def teacher_count(subject)
    self.itl_organizations.collect{|o| o.teacher_count(subject)}.sum 
  end

  def student_count(subject)
    self.itl_organizations.collect{|o| o.student_count(subject)}.sum
  end

  def tlt_sessions(subject, since_date)
    self.organizations.collect{|o| o.tlt_sessions.for_subject(subject).since_date(since_date).size}.sum
  end

  def tlt_session_time(subject, since_date)
    self.organizations.collect{|o| o.tlt_sessions.for_subject(subject).since_date(since_date)}.flatten.collect{|s| s.session_length}.sum
  end

  def tlt_session_count
    self.organizations.collect{|o| o.tlt_sessions.count}.sum
  end

  def elt_final_indicators_rubric(rubric)   
  end
  
end
