class IfaPlanRemark < ActiveRecord::Base
  include PublicPersona
  attr_accessible :course_name, :ifa_plan_id, :remarks, :teacher_name, :user_id

  belongs_to :ifa_plan
  belongs_to :user

  def self.by_update_date
    order('updated_ar DESC')
  end
end
