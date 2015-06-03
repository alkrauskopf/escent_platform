class AddressType < ActiveRecord::Base
  has_many :addresses

  validates_presence_of :name
  
  def self.physical
    @physical ||= self.find_by_name("Physical")
  end  
end
