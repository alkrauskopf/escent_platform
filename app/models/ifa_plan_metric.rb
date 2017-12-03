class IfaPlanMetric < ActiveRecord::Base
  attr_accessible :act_subject_id, :entity_id, :entity_type, :is_uptodate
  include PublicPersona

  belongs_to :entity, :polymorphic => true
  belongs_to :act_subject

  has_many  :metric_cells, :class_name => 'IfaPlanMetricCell'

  def self.for_subject(subject)
    where('act_subject_id = ?', subject.id)
  end

  def self.up_to_date
    where('is_uptodate')
  end

  def self.update_needed
    where('is_uptodate = ?', false)
  end

  def up_to_date?
    self.is_uptodate
  end

  def subject
    self.act_subject
  end

end
