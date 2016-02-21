class ItlTemplate < ActiveRecord::Base

  include PublicPersona

  belongs_to  :organization
  has_many :itl_template_app_methods, :dependent => :destroy
  has_many :app_methods, :through => :itl_template_app_methods

  has_many :tlt_sessions

  has_many :itl_template_filters, :dependent => :destroy
  has_many :tl_activity_type_tasks, :through => :itl_template_filters

  scope :enabled, :conditions => { :is_enabled => true}, :order=> "name"
  scope :disabled, :conditions => { :is_enabled => false}, :order=> "name"
  scope :editable, :conditions => { :is_enabled => false}, :order=> "name"
  scope :default, :conditions => { :is_default => true}, :order=> "name"


  validates_presence_of :name, :message => 'Template Must Have A Name'  
  
  def editable?
    self.is_editable
  end

  def enabled?
    self.is_enabled
  end

  def empty?
    self.app_methods.empty?
  end

  def default?
    self.is_default
  end

  def using_method?(method)
      self.app_methods.include?(method)
  end

  def filters_for_method(method)
    self.itl_template_filters.select{|f| method.tl_activity_types.include?(f.tl_activity_type_task.tl_activity_type)}
  end

  def useable?
    useable = !self.empty?  
    if useable
      self.app_methods.each do |method|
        if !self.organization.itl_org_option.app_methods.include?(method)
          useable =false
        end
      end
    end
    useable
  end

  def useable_for_org?(org)
    useable = !self.empty?  
    if useable
      self.app_methods.each do |method|
        if (!org.itl_org_option || org.itl_org_option.app_methods.empty? || !org.itl_org_option.app_methods.include?(method))
          useable =false
        end
      end
    end
    useable
  end

end
