class ContentStatus < ActiveRecord::Base



  def self.available
    where('name = ?', "Available").first
  end

  def self.not_deleted
    where('name != ?', 'Deleted')
  end
end
