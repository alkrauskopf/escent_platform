class ItlSummary < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization
  belongs_to :organization_type
  belongs_to :classroom
  belongs_to :subject_area
  belongs_to :itl_belt_rank
  
  has_many  :itl_summary_strategies, :dependent => :destroy

  named_scope :for_subject, lambda{|subject| {:conditions => ["subject_area_id = ? ", subject.id], :order => "created_at DESC"}}
  named_scope :since_date, lambda{|begin_date| {:conditions => ["yr_mnth_of >= ? ", begin_date], :order => "yr_mnth_of ASC"}}  
  named_scope :before_date, lambda{|end_date| {:conditions => ["yr_mnth_of <= ? ", end_date], :order => "yr_mnth_of ASC"}}  
  named_scope :between_dates, lambda{|begin_date,end_date| {:conditions => ["yr_mnth_of >= ? AND yr_mnth_of <= ? ", begin_date, end_date], :order => "yr_mnth_of ASC"}}  
  named_scope :for_belt, lambda{|belt| {:conditions => ["itl_belt_rank.id = ? ", belt.id], :order => "yr_mnth_of ASC"}}  
  named_scope :belt_score_min, lambda{|score| {:conditions => ["itl_belt_rank.rank_score >= ? ", score], :include => "itl_belt_rank", :order => "yr_mnth_of ASC"}}  



def itl_sessions
  if (self.organization && self.subject_area && self.classroom && self.itl_belt_rank)
    sessions = self.classroom.tlt_sessions.between_dates(self.yr_mnth_of, self.yr_mnth_of.end_of_month).for_belt(self.itl_belt_rank).final
  else
    sessions = []
  end
  sessions
end

end
