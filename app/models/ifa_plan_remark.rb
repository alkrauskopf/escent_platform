class IfaPlanRemark < ActiveRecord::Base
  include PublicPersona
  attr_accessible :course_name, :ifa_plan_id, :remarks, :teacher_name, :user_id

  belongs_to :ifa_plan
  belongs_to :user

  def self.by_update_date
    order('updated_at DESC')
  end

  def destroyable?(user)
    self.teacher? && user == self.teacher
  end

  def plan
    self.ifa_plan
  end

  def teacher
    self.user
  end

  def teacher?
    !self.user.nil?
  end

end
