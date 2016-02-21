class ClassroomPeriodUser < ActiveRecord::Base

  belongs_to :classroom_period
  belongs_to :user
  
  scope :teachers, :conditions => {:is_teacher => true}
  scope :students, :conditions => {:is_student => true}

  scope :for_teacher, lambda{|teacher| {:conditions => ["user_id = ? && is_teacher", teacher.id]}}
  scope :for_student, lambda{|student| {:conditions => ["user_id = ? && is_student", student.id]}}



end
