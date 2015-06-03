class IstaGroup < ActiveRecord::Base
  include PublicPersona
  
  has_many :ista_activities
  has_many   :ista_case_allocations
  
  named_scope :academics, :conditions => ["group_code = ?", "A"], :order => 'level'
  named_scope :electives, :conditions => ["group_code = ?", "E"], :order => 'level'
  named_scope :other, :conditions => ["group_code = ?", "O"], :order => 'level'

end
