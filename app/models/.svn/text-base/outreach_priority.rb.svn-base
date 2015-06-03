class OutreachPriority < ActiveRecord::Base
  include PublicPersona

  acts_as_tree :order => "name"


  has_many  :children,
            :class_name   => "OutreachPriority",
            :foreign_key  => "parent_id",
            :order        => "name"


  has_and_belongs_to_many :users
  has_and_belongs_to_many :topics
  has_and_belongs_to_many :outreach_priority_groups

  validates_presence_of :name
  validates_presence_of :parent_id

  def self.auto_complete_on(query)
    OutreachPriority.find(:all, :conditions => ["name LIKE ?", '%' + query + '%'], :order => "name").flatten.uniq.sort_by(&:name)
  end

end
