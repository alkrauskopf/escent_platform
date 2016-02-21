class StudentSubjectDemographic < ActiveRecord::Base

  belongs_to :user
  belongs_to :act_subject  
  
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}

end
