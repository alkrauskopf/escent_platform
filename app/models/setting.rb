class Setting < ActiveRecord::Base
  acts_as_list
  
  has_many :setting_values
  
end
