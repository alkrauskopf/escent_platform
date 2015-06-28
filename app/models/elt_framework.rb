class EltFramework < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization

  has_many :elt_org_options
  has_many :elt_cycles, :dependent => :destroy
  has_many :elt_types, :dependent => :destroy
  has_many :elt_elements, :dependent => :destroy

  def cycles
    self.elt_cycles
  end

  def activities
    self.elt_types
  end

  def elements
    self.elt_elements
  end
end
