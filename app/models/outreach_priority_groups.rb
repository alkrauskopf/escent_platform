class OutreachPriorityGroups < ActiveRecord::Base
  has_and_belongs_to_many :outreach_priorities , :foreign_key => "outreach_priority_group_id" 
  include PublicPersona
  
  validates_presence_of :name 
  validates_uniqueness_of :name , :allow_nil => false
  attr_accessor :outreach_priority_ids
  
  def outreach_priority_obj
    arr = []
    self.outreach_priorities.destroy unless new_record?
    outreach_priority_ids.each do |u|
      arr << OutreachPriority.find(u) rescue nil
    end if outreach_priority_ids.present?
    arr.compact  
  end
  
end
