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

  def destroyable?(org)
    (self.organization == org && !self.active?)
  end

  def editable?(org)
    (self.organization == org && !self.active?)
  end

  def elements
    self.elt_elements
  end

end
