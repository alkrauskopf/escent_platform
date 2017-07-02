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
      {:conditions => ["act_subject_id = ? ", subject.id]}
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

  def self.for_entity_class(entity_class)
    IfaDashboard.where("ifa_dashboardable_type = ?", entity_class).order('period_end DESC')
  end

  def org_name
    self.organization.nil? ? 'No Organization' : self.organization.short_name
  end

  def redashed?
    self.is_replaced
  end

  def self.redashed
    where("is_replaced", false).order('period_end').reverse
  end

  def self.by_date
    order('period_end').reverse
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

  def self.for_subject_period(subject, period_date)
    where('act_subject_id = ? && period_end = ?', subject.id, period_date).first rescue nil
  end

  def cell_for(level, strand)
    self.ifa_dashboard_cells.for_range_and_strand(level, strand).empty? ? nil : self.ifa_dashboard_cells.for_range_and_strand(level, strand).first rescue nil
  end

  def cells_for_standard(standard)
    self.ifa_dashboard_cells.for_standard(standard)
  end

  def total_points
    self.ifa_dashboard_cells.map{|c| c.fin_points}.sum
  end

  def total_c_points
    self.ifa_dashboard_cells.map{|c| c.cal_points}.sum
  end

  def total_answers
    self.ifa_dashboard_cells.map{|c| c.finalized_answers}.sum
  end

  def total_c_answers
    self.ifa_dashboard_cells.map{|c| c.calibrated_answers}.sum
  end

  def entity
    self.ifa_dashboardable
  end

  def entity_class
    self.ifa_dashboardable.class.to_s
  end

  def entity_unkown?
    self.entity_class != 'User' && self.entity_class != 'Classroom' && self.entity_class != 'Organization'
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

  def sms_score(standard)
    self.ifa_dashboard_sms_scores.for_standard(standard).first rescue nil
  end

  def score_boundary_minimum(standard)
    self.ifa_dashboard_cells.for_standard(standard).collect{|c| c.act_score_range.lower_score}.min
  end
  def score_boundary_maximum(standard)
    self.ifa_dashboard_cells.for_standard(standard).collect{|c| c.act_score_range.upper_score}.max
  end

  def level_range(standard)
    self.ifa_dashboard_cells.levels_for_standard(standard)
  end

  def calculated_standard_score(standard, option={})
    score = 0
    if option[:calibrated]
      pct_score = self.calibrated_answers > 1 ? (self.cal_points/self.calibrated_answers.to_f) : 0.0
    else
      pct_score = self.finalized_answers > 1 ? (self.fin_points/self.finalized_answers.to_f) : 0.0
    end
    if pct_score > 0.25
      max_score = self.level_range(standard).last.upper_score
      upper_min_score = self.level_range(standard).first.upper_score
      score = upper_min_score + (pct_score * ((max_score.to_f - upper_min_score.to_f)).to_i)
    else
      score = self.level_range(standard).first.upper_score
    end
    score
  end

end
