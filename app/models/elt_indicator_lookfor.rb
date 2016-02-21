class EltIndicatorLookfor < ActiveRecord::Base

  belongs_to :elt_indicator  
  
  scope :all, :order => "position ASC"

end
