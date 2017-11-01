class UserGuardian < ActiveRecord::Base
  attr_accessible :email_address, :first_name, :last_name, :phone, :user_id
  include PublicPersona

  belongs_to :user

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email_address
  validates_format_of :email_address, :with => /^[\w._%+-]+@[\w.-]+\.[\w]{2,6}$/, :message => 'invalid format',
                      :allow_nil => false



  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def name
    self.full_name
  end

  def last_name_first
    "#{self.last_name}, #{self.first_name}"
  end

  def student
    self.user
  end
end
