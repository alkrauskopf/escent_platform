class IfaDashboard < ActiveRecord::Base
  include PublicPersona
  
  
  belongs_to :ifa_dashboardable, :polymorphic => true
  
  belongs_to :organization
  belongs_to :act_subject

  
  
  has_many :ifa_dashboard_cells, :dependent => :destroy
  has_many :ifa_dashboard_sms_scores, :dependent => :destroy 

  scope :for_subject_since, lambda{|subject, begin_date|
      {:conditions => ["act_subject_id = ? && period_end >= ?", subject.id,  begin_date], :order => "period_end ASC" }
      }
  scope :for_subject, lambda{|subject|
      {:conditions => ["act_subject_id = ? ", subject.id], :order => "period_end ASC" }
      }

  scope :since, lambda{|date|
      {:conditions => ["period_end >= ? ", date], :order => "period_end ASC" }
      }

  scope :up_to, lambda{|date|
      {:conditions => ["period_end <= ? ", date], :order => "period_end ASC" }
      }

  scope :for_period, lambda{|date|
      {:conditions => ["period_end = ? ", date]}
      }

  scope :org_subject_after_date, lambda{|entity_class, org, subject, period|
    {:conditions => ["organization_id = ? AND act_subject_id = ? AND ifa_dashboardable_type = ? AND period_end >= ?", org.id, subject.id, entity_class, period ]}
  }

  scope :for_subject_between, lambda{|subject, begin_date, end_date|
    {:conditions => ["act_subject_id = ? && period_end >= ? && period_end <= ?", subject.id,  begin_date, end_date], :order => "period_end ASC" }
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

  def self.subject_between_periods(subject, start_date, end_date)
    where('act_subject_id = ? && period_end >= ? && period_end <= ?', subject.id, start_date, end_date)
  end

  def cell_for(level, strand)
    self.ifa_dashboard_cells.for_range_and_strand(level, strand).empty? ? nil : self.ifa_dashboard_cells.for_range_and_strand(level, strand).first
  end
  def cells_for_standard(standard)
    self.ifa_dashboard_cells.for_standard(standard)
  end

  def entity_name
    if self.ifa_dashboardable.nil?
      name = "Undefined"
    elsif self.ifa_dashboardable.class.to_s == 'User'
      name = self.ifa_dashboardable.full_name
    elsif self.ifa_dashboardable.class.to_s == 'Classroom'
      name = self.ifa_dashboardable.name
    elsif self.ifa_dashboardable.class.to_s == 'Organization'
      name = self.ifa_dashboardable.short_name
    else
      name = 'Undefined'
    end
    name
  end

  def score_for_standard(standard)
    self.ifa_dashboard_sms_scores.for_standard(standard).first rescue nil
  end
end
