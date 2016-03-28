class EltElement < ActiveRecord::Base

  include PublicPersona
  
  belongs_to  :organization
  belongs_to :elt_framework
  belongs_to :elt_standard

  has_many :elt_indicators, :dependent => :destroy
  has_many :elt_case_notes, :dependent => :destroy
  has_many :elt_plan_actions, :as => :scope, :dependent => :destroy
  has_many :elt_cycle_elements, :dependent => :destroy
  has_many :cycles, :through => :elt_cycle_elements, :source => :elt_cycle, :uniq=>true
  
  validates_presence_of :name
  validates_presence_of :abbrev
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '
  
  scope :active, :conditions => ["is_active"], :order => 'position ASC'
  scope :all, :order => 'position ASC'

  def active?
    self.is_active
  end

  def siblings
    self.elt_framework ? (self.elt_framework.elt_elements.all.select{ |e| e!= self }): []
  end

  def supporting_comments(cycle, org)
    comments = []
    self.elt_case_notes(cycle).each do |indicator|
      evidences << indicator.elt_case_indicators.for_org(org).flatten
    end
    evidences.flatten.compact
  end

  def lookfors(activity)
    self
  end

  def standard
    self.elt_standard rescue nil
  end

  def self.for_standard(std)
    where('elt_standard_id = ?', std.id).order('position ASC')
  end
  def organization
    !self.standard.nil? ? self.standard.organization : nil
  end

  def destroyable?(org)
    (self.organization == org && !self.active?)
  end

  def editable?(org)
    (self.organization == org)
  end

end
