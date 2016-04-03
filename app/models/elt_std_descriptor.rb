class EltStdDescriptor < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_std_indicator

  validates_presence_of :description, :message => 'Indicator Description Required'
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '

  def indicator
    self.indicator? ? self.elt_std_indicator : nil
  end

  def indicator?
    self.elt_std_indicator.nil? ? false : true
  end

  def element?
    self.indicator? ? (self.indicator.element.nil? ? false : true) : false
  end

  def element
    self.element? ? self.indicator.element : nil
  end

  def self.by_position
    order('position ASC')
  end

end
