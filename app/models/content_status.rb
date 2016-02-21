class ContentStatus < ActiveRecord::Base


  scope :available,  :conditions => ["name = ? ", "Available"]

  def self.available
    @available ||= self.find_by_name("Available")
  end
end
