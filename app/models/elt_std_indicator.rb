class EltStdIndicator < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_element

  has_many :elt_std_descriptors, :dependent => :destroy
  has_many :elt_related_indicators, :dependent => :destroy
  has_many :elt_indicators, :through => :elt_related_indicators, :uniq=>true
  has_many :elt_case_analyses, :dependent => :destroy

  validates_presence_of :description, :message => 'Indicator Description Required'
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '

  def informing_indicators
    self.elt_indicators
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

  def self.by_position
    sort_by{|i| i.position}
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
