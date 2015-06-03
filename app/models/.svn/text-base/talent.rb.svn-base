class Talent < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id  
  
  def self.auto_complete_on(query)
    Talent.find(:all, :conditions => ["name LIKE ?", '%' + query + '%'], :order => "name")
  end
  
end