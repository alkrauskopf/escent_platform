class AppMethodLogRating < ActiveRecord::Base

  belongs_to  :app_method

  named_scope :ratings,   :conditions => { :measure => "rating" }
  named_scope :impacts,   :conditions => { :measure => "impact" }

end
