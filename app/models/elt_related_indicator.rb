class EltRelatedIndicator < ActiveRecord::Base

  belongs_to :elt_indicator 
#  belongs_to :lookfor, :class_name => 'EltIndicator', :foreign_key => "related_indicator_id"
  belongs_to :elt_std_indicator

 # scope :for_lookfor, lambda{|lf_id| {:conditions => ["related_indicator_id = ? ", lf_id]}}

  def self.for_informing_indicator(ind)
    where('elt_indicator_id = ?', ind.id)
  end

end
