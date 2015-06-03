class ContentStatus < ActiveRecord::Base


  named_scope :available,  :conditions => ["name = ? ", "Available"]

  def self.available
    @available ||= self.find_by_name("Available")
  end
end
