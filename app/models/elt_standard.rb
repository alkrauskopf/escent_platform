class EltStandard < ActiveRecord::Base
  include PublicPersona

  belongs_to :organization
  belongs_to :share_rubric, :class_name=> 'Rubric', :foreign_key => :rubric_id

  has_many :elt_elements, :dependent => :destroy
  has_many :rubrics, :as => :scope, :order => "position", :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :abbrev


  def self.public
    where('is_public').order("abbrev ASC")
  end

  def self.for_orphans
    where('is_active = ?', false).select{|s| s.elt_elements.empty?}.first rescue nil
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

  def indicators
    self.elt_elements.empty? ? [] : self.elt_elements.collect{|e| e.elt_indicators}.flatten
  end

  def case_indicators
    self.indicators.empty? ? [] : self.indicators.collect{|i| i.elt_case_indicators}.flatten
  end

  def cases
    self.case_indicators.empty? ? [] : self.case_indicators.collect{|ci| ci.elt_case}.uniq
  end

  def destroyable?(org)
    (self.organization == org && !self.active? && self.case_indicators.empty?)
  end

  def editable?(org)
    (self.organization == org)
  end

  def elements
    self.elt_elements
  end

  def self.all_elements
    self.collect{|s| s.elt_elements}.flatten.compact
  end

  def use_rubric?
    self.use_rubric
  end

  def rubric?
    !self.active_rubrics.empty?
  end

  def max_rubric
    self.rubric? ? self.rubrics.active.by_score.last : nil
  end

  def shareable_rubrics
    self.share_rubric ? self.active_rubrics.select{|r| self.share_rubric.score <= r.score} : []
  end

  def active_rubrics
    self.use_rubric? ? self.rubrics.active : []
  end

end
