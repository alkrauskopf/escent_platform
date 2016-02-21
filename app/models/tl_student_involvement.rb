class TlStudentInvolvement < ActiveRecord::Base



  scope :involve,   :conditions => { :measure => "involve" }
  scope :impact,   :conditions => { :measure => "impact" }
  
end
