class ClassroomPeriod < ActiveRecord::Base
  include PublicPersona

  belongs_to :classroom
  
  has_many :classroom_period_users, :dependent => :destroy
  has_many :users, :through => :classroom_period_users
  has_many :tlt_sessions

  has_one :itl_org_option

  has_many   :survey_schedules, :as => :entity, :dependent => :destroy

  validates_presence_of :classroom_id, :message => 'must be defined.  ' 
  validates_presence_of :name, :message => 'must be defined.  '
  validates_numericality_of :week_duration, :greater_than => 0, :message => 'must > 0.  '


def teachers
  self.classroom_period_users.teachers.collect{|u| u.user}.sort_by{|t| t.last_name.upcase}
end

def teacher_ids
  self.classroom_period_users.teachers.collect{|u| u.user_id}
end

def teacher_list
  unless self.teachers.empty?
    self.teachers.collect{|t| t.last_name}.uniq.join(", ")
  else
    ""
  end
end

def students
  self.classroom_period_users.students.collect{|u| u.user}
end

def student_ids
  self.classroom_period_users.students.collect{|u| u.user_id}
end

def student?(user)
  self.students.include?(user)
end

def teacher?(user)
  self.teachers.include?(user)
end

def ctl_training?
  self.itl_org_option
end

end
