class IfaUserOption < ActiveRecord::Base


  include PublicPersona

  belongs_to :user
  
  belongs_to :act_master
  belongs_to :act_score_range
  belongs_to :act_standard
  belongs_to :act_rel_reading

end
