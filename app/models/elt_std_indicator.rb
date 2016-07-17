class EltStdIndicator < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_element

  has_many :elt_std_descriptors, :dependent => :destroy
  has_many :elt_related_indicators, :dependent => :destroy
  has_many :elt_indicators, :through => :elt_related_indicators, :uniq=>true

  validates_presence_of :description, :message => 'Indicator Description Required'
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '

  scope :by_position, :order => ('position ASC')

  def informing_indicators
    self.elt_indicators
  end

  def org_cycle_findings(org,cycle,options={})
   if options[:key_only]
     findings = self.elt_indicators.active.map{|i| i.elt_case_indicators.for_org_cycle(org,cycle).key_findings}.flatten rescue []
   else
     findings = self.elt_indicators.active.map{|i| i.elt_case_indicators.for_org_cycle(org,cycle)}.flatten rescue []
   end
    findings
  end

  def cycle_findings(cycle)
    self.informing_indicators.cycle_findings(cycle)
  end

  def self.active
    where('is_active').by_position
  end

  def active?
    self.is_active
  end

  def element
    self.elt_element
  end

  def element?
    self.element.nil? ? false : true
  end

  def standard?
    (self.element? && self.element.standard?) ? true : false
  end
  def standard
    self.standard? ? self.element.standard : nil
  end

  def self.by_element
    self.sort_by{|i| [i.element.abbrev]}.by_position
  end

  def self.for_element(element)
    where('elt_element_id = ?', element.id).by_position
  end

  def descriptors
    self.elt_std_descriptors
  end

end
