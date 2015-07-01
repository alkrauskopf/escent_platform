class EltFramework < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization

  has_many :elt_org_options
  has_many :elt_cycles, :dependent => :destroy
  has_many :elt_types, :dependent => :destroy
  has_many :elt_elements, :dependent => :destroy
  has_many :elt_cases, :through => :elt_types


  def cycles
    self.elt_cycles
  end

  def activities
    self.elt_types
  end


  def master_activity
    self.elt_types.masters.first rescue nil
  end

  def master_activity
    self.elt_types.first
  end

  def elements
    self.elt_elements
  end
end
