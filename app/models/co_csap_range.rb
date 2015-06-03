class CoCsapRange < ActiveRecord::Base

  belongs_to :act_subject
  
 
  named_scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  named_scope :no_na, {:conditions => ["upper_score > ?", 0]}

  
end
