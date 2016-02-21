class AppMethodLogRating < ActiveRecord::Base

  belongs_to  :app_method

  scope :ratings,   :conditions => { :measure => "rating" }
  scope :impacts,   :conditions => { :measure => "impact" }

end
