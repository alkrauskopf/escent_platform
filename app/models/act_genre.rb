class ActGenre < ActiveRecord::Base

  include PublicPersona
  
  has_many :act_rel_readings

  def active?
    self.is_active
  end

  def self.active
    where('is_active').order('name ASC')
  end

end
