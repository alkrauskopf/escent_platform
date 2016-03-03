class ApplicableScope < ActiveRecord::Base
  belongs_to :authorization_level

#  scope :for_classrooms, :conditions => ["name = ?", "Classroom"]
#  scope :for_organizations, :conditions => ['name = ?', 'Organization']
#  scope :for_apps, :conditions =>  ['name = ?', 'CoopApp']
#  scope :for_users, :conditions =>  ['name = ?', 'User']
#  scope :for_content, :conditions =>  ['name = ?', 'Content']


  def self.for_classroom
    self.where('name = ?', 'Classroom')
  end
  def self.for_organizations
    self.where('name = ?', 'Organization')
  end
  def self.for_apps
    self.where('name = ?', 'CoopApp')
  end
  def self.for_users
    self.where('name = ?', 'User')
  end
  def self.for_content
    self.where('name = ?', 'Content')
  end
  def self.for_scope(scope)
    self.where('name = ?', scope.class.to_s)
  end
end
