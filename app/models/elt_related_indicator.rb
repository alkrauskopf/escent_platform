class EltRelatedIndicator < ActiveRecord::Base

  belongs_to :elt_indicator 
  belongs_to :lookfor, :class_name => 'EltIndicator', :foreign_key => "related_indicator_id"
  scope :for_lookfor, lambda{|lf_id| {:conditions => ["related_indicator_id = ? ", lf_id]}}

end
