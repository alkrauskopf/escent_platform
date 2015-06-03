class ApplicableScope < ActiveRecord::Base
  belongs_to :authorization_level
 
  
  
    named_scope :for_classrooms, :conditions => ["name = ?", "Classroom"]

end
