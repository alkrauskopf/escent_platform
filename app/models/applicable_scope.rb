class ApplicableScope < ActiveRecord::Base
  belongs_to :authorization_level

  scope :for_classrooms, :conditions => ["name = ?", "Classroom"]

end
