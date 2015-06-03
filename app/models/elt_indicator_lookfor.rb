class EltIndicatorLookfor < ActiveRecord::Base

  belongs_to :elt_indicator  
  
  named_scope :all, :order => "position ASC"

end
