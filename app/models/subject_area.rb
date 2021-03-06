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

  belongs_to :act_subject
        
  validates_presence_of :name

  scope :top, :conditions => ["parent_id IS NULL"], :order => "name"
  scope :pd, :conditions => ["name = ?","Professional Development"]
  scope :core, :conditions => ["parent_id IS NULL AND is_core AND is_academic"], :order => "name"
  scope :noncore, :conditions => ["parent_id IS NULL AND !is_core AND is_academic"], :order => "name"
  scope :academic, :conditions => ["is_academic"], :order => "name"
  
  def self.auto_complete_on(query)
    where('name LIKE ?', '%' + query + '%').order('name')
  end

  def self.by_name
   order('name ASC')
  end

  def self.all_parents
    where('parent_id is NULL').order('name')
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
