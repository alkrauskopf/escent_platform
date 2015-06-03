class IfaDashboard < ActiveRecord::Base
  include PublicPersona
  
  
  belongs_to :ifa_dashboardable, :polymorphic => true
  
  belongs_to :organization
  belongs_to :act_subject

  
  
  has_many :ifa_dashboard_cells, :dependent => :destroy
  has_many :ifa_dashboard_sms_scores, :dependent => :destroy 

  named_scope :for_subject_since, lambda{|subject, begin_date| 
      {:conditions => ["act_subject_id = ? && period_end >= ?", subject.id,  begin_date], :order => "period_end ASC" }
      }
  named_scope :for_subject, lambda{|subject| 
      {:conditions => ["act_subject_id = ? ", subject.id], :order => "period_end ASC" }
      }

  named_scope :since, lambda{|date| 
      {:conditions => ["period_end >= ? ", date], :order => "period_end ASC" }
      }

  named_scope :up_to, lambda{|date| 
      {:conditions => ["period_end <= ? ", date], :order => "period_end ASC" }
      }

  named_scope :for_period, lambda{|date| 
      {:conditions => ["period_end = ? ", date]}
      }

end
