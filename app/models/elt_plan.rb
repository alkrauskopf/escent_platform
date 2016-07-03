class EltPlan < ActiveRecord::Base
  include PublicPersona
 
  belongs_to :organization
  belongs_to :elt_cycle
  
  has_many :elt_plan_actions, :dependent => :destroy
  
  scope :opened, :conditions => ["is_open"]
  scope :for_cycle, lambda{|cycle| {:conditions => ["elt_cycle_id = ?", cycle.id]}}
  scope :for_provider, lambda{|provider| {:include => :elt_cycle, :conditions => ["elt_cycles.organization_id = ?", provider.id], :order => "elt_plans.updated_at DESC"}}
  scope :for_framework, lambda{|framework| {:include => :elt_cycle, :conditions => ["elt_cycles.elt_framework_id = ?", framework.id], :order => "elt_plans.updated_at DESC"}}


  def open?
    self.is_open
  end

  def closed?
    !self.is_open
  end

  def action_for_entity(entity)
    self.elt_plan_actions.for_entity(entity).first rescue nil
  end

  def action_for_scope(type, id)
    self.elt_plan_actions.for_scope(type, id).first rescue nil
  end

  def rubric_for_entity(entity)
    (self.action_for_entity(entity).nil? || !self.action_for_entity(entity).rubric) ? nil : self.action_for_entity(entity).rubric
  end

  def background_for_entity(entity)
    (self.action_for_entity(entity).nil? || !self.action_for_entity(entity).rubric || self.action_for_entity(entity).rubric.color_background.empty?) ? "transparent" : self.action_for_entity(entity).rubric.color_background
  end
  
  def font_for_entity(entity)
    (self.action_for_entity(entity).nil? || !self.action_for_entity(entity).rubric || (self.action_for_entity(entity).rubric.color_font == "")) ? "#000000" : self.action_for_entity(entity).rubric.color_font
  end

  def reassign_it(new_cycle_id)
    self.update_attributes(:elt_cycle_id => new_cycle_id)
  end

end
