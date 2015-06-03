class DleCoachAssignment < ActiveRecord::Base

  belongs_to :user 
  
  belongs_to :coachee, :class_name => 'User', :foreign_key => "teacher_id"


end
