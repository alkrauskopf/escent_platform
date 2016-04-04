class EltStandard < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization
  has_many :elt_elements, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :abbrev


  def self.public
    where('is_public').order("abbrev ASC")
  end

  def public?
    self.is_public
  end

  def self.active
    where('is_active').order("abbrev ASC")
  end

  def active?
    self.is_active
  end

  def self.org_available(org)
    where('organization_id = ? OR (is_active AND is_public)', org.id).order("created_at DESC")
  end

  def self.org_available_elements(org)
    org_available(org).collect{|s| s.elements.active}.compact.flatten
  end

  def destroyable?(org)
    (self.organization == org && !self.active?)
  end

  def editable?(org)
    (self.organization == org && !self.active?)
  end

  def elements
    self.elt_elements
  end

  def self.all_elements
    self.collect{|s| s.elt_elements}.flatten.compact
  end

end
