class EltPlanType < ActiveRecord::Base

  include PublicPersona
 
  belongs_to :organization

  has_many :rubrics, :as => :scope, :order => "position", :dependent => :destroy

  scope :active, :conditions => ["is_active"]
  scope :school_plan, :conditions => ["abbrev = ?", "SCHOOL"]
  
  def active?
    self.is_active
  end  

  def rubric?
    true
  end  

  def rubric_names
    self.rubrics.collect{|r| r.name.upcase}.join(", ")
  end   

  def self.school
    EltPlanType.school_plan.first rescue nil
  end 

end
