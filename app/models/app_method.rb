class AppMethod < ActiveRecord::Base

  belongs_to  :coop_app

  has_many :tlt_session_app_methods, :dependent => :destroy
  has_many :tlt_sessions, :through => :tlt_session_app_methods
  has_many :itl_template_app_methods, :dependent => :destroy
  has_many :itl_templates, :through => :tlt_template_app_methods
  has_many  :tl_activity_types
  has_many :itl_org_option_app_methods, :dependent => :destroy
  has_many :itl_org_options, :through => :itl_org_option_app_methods
  has_many :app_method_log_ratings, :dependent => :destroy
    
  scope :timed, :conditions => ["is_timed"]
  scope :not_timed, :conditions => { :is_timed => false}, :order=> "name"
  scope :by_position, :order => 'position'
  scope :by_desc_position, :order => 'position DESC'
  scope :rs, {:conditions => ["abbrev = ?", "RS"]}
  scope :ie, {:conditions => ["abbrev = ?", "IE"]}

  def timed?
    self.is_timed
  end

  def rs?
    self.abbrev == "RS"
  end
  def self.strategy
    self.rs.first rescue nil
  end
  def tasks
    self.tl_activity_types.collect{|t| t.tl_activity_type_tasks}.flatten
  end

end
