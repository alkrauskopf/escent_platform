class EltCaseAnalysis < ActiveRecord::Base

  include PublicPersona

  belongs_to :elt_case
  belongs_to :elt_element
  belongs_to :elt_std_indicator
  belongs_to :provider, :class_name => 'Organization', :foreign_key => 'provider_id'
  belongs_to :rubric

  def element
    self.elt_element
  end

  def std_indicator
    self.elt_std_indicator
  end

  def organization
    (!self.elt_case.nil? && !self.elt_case.organization.nil?) ? self.elt_case.organization : nil
  end

  def standard
    (!self.element.nil? && !self.element.standard.nil?) ? self.element.standard : nil
  end

  def rating
    (!self.rubric.nil?) ? self.rubric.name : 'Undefined'
  end

  def score
    (!self.rubric.nil?) ? self.rubric.score : 0
  end

end
