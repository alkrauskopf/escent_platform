class BlogPanel < ActiveRecord::Base
 
  include PublicPersona 
  
  has_and_belongs_to_many :users
  has_many :blogs

  def can_be_delete?
    users.size.zero?
  end
  
  def self.default
    find 1
  end  
  
  # def before_save
  #    active = false if active.blank?
  #  end
end
