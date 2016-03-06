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

  named_scope :org_subject_after_date, lambda{|entity_class, org, subject, period|
    {:conditions => ["organization_id = ? AND act_subject_id = ? AND ifa_dashboardable_type = ? AND period_end >= ?", org.id, subject.id, entity_class, period ]}
  }


  def self.for_entity(entity_class, entity_id, period)
    IfaDashboard.where("ifa_dashboardable_type = ? AND ifa_dashboardable_id = ? AND period_end = ?", entity_class, entity_id, period ).first
  end

  def period_beginning
    self.period_end.beginning_of_month
  end
  def period_ending
    self.period_end.end_of_month
  end
end
