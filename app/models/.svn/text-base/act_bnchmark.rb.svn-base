class ActBnchmark < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :act_score_range
  belongs_to :act_standard
  belongs_to :act_subject
  
  validates_presence_of :act_subject_id
  validates_presence_of :act_standard_id
  validates_presence_of :act_score_range_id
  validates_presence_of :type
  
end
