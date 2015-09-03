class EltElement < ActiveRecord::Base

  include PublicPersona
  
  belongs_to  :organization
  belongs_to :elt_framework

  has_many :elt_indicators, :dependent => :destroy
  has_many :elt_case_notes, :dependent => :destroy
  has_many :elt_plan_actions, :as => :scope, :dependent => :destroy
  
  validates_presence_of :name
  validates_presence_of :abbrev
  validates_numericality_of :position, :greater_than => 0, :message => 'must > 0.  '
  
  named_scope :active, :conditions => ["is_active"], :order => 'position ASC'
  named_scope :all, :order => 'position ASC'

  def active?
    self.is_active
  end


  def siblings
    self.elt_framework ? (self.elt_framework.elt_elements.all.select{ |e| e!= self }): []
  end

end
