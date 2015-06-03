class TltSessionAppMethod < ActiveRecord::Base

  belongs_to  :app_method
  belongs_to  :tlt_session
  
end
