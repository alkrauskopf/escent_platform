class SubjectArea < ActiveRecord::Base
 include PublicPersona
 
  acts_as_tree :order => "name"    
  has_many :classrooms 
  has_many :contents
  has_many :tlt_sessions
  has_many :tlt_dashboards, :dependent => :destroy
  has_many :tlt_survey_responses
  has_many :tlt_diagnostics
  has_many :itl_summaries, :dependent => :destroy
  has_many :survey_schedules
 
  has_many :coop_app_resources_subjects, :dependent => :destroy
  has_many :coop_apps, :through => :coop_app_resources_subjects
  
  has_many   :ista_case_allocations, :as => :activity, :dependent => :destroy  
  has_many :elt_cases 
        
  validates_presence_of :name

  named_scope :top, :conditions => ["parent_id IS NULL"], :order => "name"
  named_scope :pd, :conditions => ["name = ?","Professional Development"]
  named_scope :core, :conditions => ["parent_id IS NULL AND is_core AND is_academic"], :order => "name"
  named_scope :noncore, :conditions => ["parent_id IS NULL AND !is_core AND is_academic"], :order => "name"
  named_scope :academic, :conditions => ["is_academic"], :order => "name"
  
  def self.auto_complete_on(query)
    SubjectArea.find(:all, :conditions => ["name LIKE ?", '%' + query + '%'], :order => "name")
  end

 
  def self.all_parents
    SubjectArea.find(:all, :conditions => ["parent_id is NULL"], :order => "name")
  end

  def self.english
    SubjectArea.find(:all, :conditions => ["parent_id is NULL AND name = ?", "English"])
  end

  def child?
    !self.parent_id.nil?
  end
  
  def parent?
    self.parent_id.nil?
  end

  def parent_subject
    self.parent_id.nil? ? self : (self.parent ? self.parent : self)
  end
  
  def all_children
    (self.children + self.children.collect{|child| child.children}).flatten
  end  

  def pd?
      self.name == "Professional Development"
  end


end
