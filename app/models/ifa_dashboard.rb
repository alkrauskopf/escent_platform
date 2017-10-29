class IfaDashboard < ActiveRecord::Base
  include PublicPersona
  
  
  belongs_to :ifa_dashboardable, :polymorphic => true
  
  belongs_to :organization
  belongs_to :act_subject

  has_many :ifa_dashboard_cells, :dependent => :destroy
  has_many :ifa_dashboard_sms_scores, :dependent => :destroy 

#  scope :for_subject_since, lambda{|subject, begin_date|
#      {:conditions => ["act_subject_id = ? && period_end >= ?", subject.id,  begin_date], :order => "period_end ASC" }
#      }
  scope :for_subject, lambda{|subject|
      {:conditions => ["act_subject_id = ? ", subject.id]}
      }

 # scope :since, lambda{|date|
 #     {:conditions => ["period_end >= ? ", date], :order => "period_end ASC" }
 #     }

 # scope :up_to, lambda{|date|
 #     {:conditions => ["period_end <= ? ", date], :order => "period_end ASC" }
 #     }

#  scope :for_period, lambda{|date|
#      {:conditions => ["period_end = ? ", date]}
#      }


#  scope :for_subject_between, lambda{|subject, begin_date, end_date|
#    {:conditions => ["act_subject_id = ? && period_end >= ? && period_end <= ?", subject.id,  begin_date, end_date], :order => "period_end ASC" }
#  }

  def self.for_subject_between(subject, begin_date, end_date)
    period_end = end_date.class == 'Date' ? end_date.end_of_month : end_date.to_date.end_of_month
    period_begin = begin_date.class == 'Date' ? begin_date.end_of_month : begin_date.to_date.end_of_month
    where("act_subject_id = ? && period_end >= ? && period_end <= ?", subject.id,  period_begin, period_end).order('period_end ASC')
  end

  def user
    self.ifa_dashboardable_type == 'User' ? self.ifa_dashboardable : nil
  end

  def subject
    self.act_subject
  end

  def self.for_subject_since(subject, begin_date)
    period_begin = begin_date.class == 'Date' ? begin_date.end_of_month : begin_date.to_date.end_of_month
    where("act_subject_id = ? && period_end >= ?", subject.id,  period_begin).order('period_end ASC')
  end

  def self.up_to(end_date)
    period_end = end_date.class == 'Date' ? end_date.end_of_month : end_date.to_date.end_of_month
    where("period_end <= ? ", period_end).order('period_end ASC')
  end

  def self.since(end_date)
    period_end = end_date.class == 'Date' ? end_date.end_of_month : end_date.to_date.end_of_month
    where("period_end >= ? ", period_end).order('period_end ASC')
  end

  def self.for_period(period)
    period_end = period.class == 'Date' ? period.end_of_month : period.to_date.end_of_month
    where('period_end = ?', period_end)
  end

  def self.for_entity(entity_class, entity_id, period)
    period_end = period.class == 'Date' ? period.end_of_month : period.to_date.end_of_month
    IfaDashboard.where("ifa_dashboardable_type = ? AND ifa_dashboardable_id = ? AND period_end = ?", entity_class, entity_id, period_end ).first
  end

  def self.for_entity_class(entity_class)
    IfaDashboard.where("ifa_dashboardable_type = ?", entity_class).order('period_end DESC')
  end

  def org_name
    self.organization.nil? ? 'No Organization' : self.organization.short_name
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
    period_end = end_date.class == 'Date' ? end_date.end_of_month : end_date.to_date.end_of_month
    period_begin = start_date.class == 'Date' ? start_date.end_of_month : start_date.to_date.end_of_month
    where('act_subject_id = ? && period_end >= ? && period_end <= ?', subject.id, period_begin, period_end)
  end

  def self.for_subject_period(subject, period_date)
    period_end = period_date.class == 'Date' ? period_date.end_of_month : period_date.to_date.end_of_month
    where('act_subject_id = ? && period_end = ?', subject.id, period_end)
  end

  def redash?
    self.needs_redash
  end

  def redash_needed
    self.update_attributes(:needs_redash => true)
  end

  def cell_for(level, strand)
    self.ifa_dashboard_cells.for_range_and_strand(level, strand).empty? ? nil : self.ifa_dashboard_cells.for_range_and_strand(level, strand).first rescue nil
  end

  def cells_for_standard(standard)
    self.ifa_dashboard_cells.for_standard(standard)
  end

  def cells_for_level(level)
    self.ifa_dashboard_cells.for_level(level)
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

  def total_level_points(level)
    self.cells_for_level(level).map{|c| c.fin_points}.sum
  end

  def total_level_c_points(level)
    self.cells_for_level(level).map{|c| c.cal_points}.sum
  end

  def total_level_answers(level)
    self.cells_for_level(level).map{|c| c.finalized_answers}.sum
  end

  def total_level_c_answers(level)
    self.cells_for_level(level).map{|c| c.calibrated_answers}.sum
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

  def calculated_weighted_score(standard, option={})
    weighted_score = 0.0
    standard.mastery_levels(self.act_subject).each do |level|
      cell_level_answers = option[:calibrated] ? self.total_level_c_answers(level).to_f : self.total_level_answers(level).to_f
      cell_level_points = option[:calibrated] ? self.total_level_c_points(level) : self.total_level_points(level)
      total_answers = option[:calibrated] ? self.calibrated_answers.to_f : self.finalized_answers.to_f
      if cell_level_answers != 0
        delta = level.upper_score - level.lower_score
        level_position = level.lower_score.to_f + delta.to_f * cell_level_points/cell_level_answers
        weighted_score += level_position * cell_level_answers
      end
    end
    weighted_score == 0.0 ? standard.mastery_levels(self.act_subject).first.lower_score : (weighted_score/total_answers).to_i
  end

end
