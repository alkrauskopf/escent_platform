class EltCaseNote < ActiveRecord::Base
  
  belongs_to :elt_case
  belongs_to :elt_element  
  
  scope :for_element, lambda{|el| {:conditions => ["elt_element_id = ?", el.id]}}


end
