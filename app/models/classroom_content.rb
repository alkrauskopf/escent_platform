class ClassroomContent < ActiveRecord::Base
  
  belongs_to :content
  belongs_to :classroom
  
  acts_as_list :scope => :classroom
  
end
