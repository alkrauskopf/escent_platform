class IstaGroup < ActiveRecord::Base
  include PublicPersona
  
  has_many :ista_activities
  has_many   :ista_case_allocations
  
  scope :academics, :conditions => ["group_code = ?", "A"], :order => 'level'
  scope :electives, :conditions => ["group_code = ?", "E"], :order => 'level'
  scope :other, :conditions => ["group_code = ?", "O"], :order => 'level'

end
