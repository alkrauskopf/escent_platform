class ClassroomPeriodUser < ActiveRecord::Base

  belongs_to :classroom_period
  belongs_to :user
  
  named_scope :teachers, :conditions => {:is_teacher => true}
  named_scope :students, :conditions => {:is_student => true}

  named_scope :for_teacher, lambda{|teacher| {:conditions => ["user_id = ? && is_teacher", teacher.id]}}
  named_scope :for_student, lambda{|student| {:conditions => ["user_id = ? && is_student", student.id]}}



end
