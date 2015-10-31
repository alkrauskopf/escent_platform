class ReligiousAffiliation < ActiveRecord::Base
  include PublicPersona
  
  acts_as_tree :order => "name"
  
#  belongs_to :channel
#  has_many :organizations

#  validates_presence_of :name

  named_scope :top, :conditions => ["parent_id IS NULL"], :order => "name"

  def self.auto_complete_on(query)
    ReligiousAffiliation.find(:all, :conditions => ["name LIKE ?", '%' + query + '%'], :order => "name").collect{|ra| [ra, ra.all_children]}.flatten.uniq.sort_by(&:name)
  end
  
  def self.all_parents
    ReligiousAffiliation.find(:all, :conditions => ["parent_id is NULL"], :order => "name")
  end
  
  def all_children
    (self.children + self.children.collect{|child| child.children}).flatten
  end  
end
