class CoGleEvidenceOutcomes < ActiveRecord::Base

  include PublicPersona

  belongs_to :act_score_range
  belongs_to :user
  belongs_to :organization  
  belongs_to :co_gle  

  has_many :act_questions, :through => :act_bench_act_questions    
  



end
