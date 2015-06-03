class EltRubricCriteria < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :elt_rubric

end
