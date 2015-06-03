class ActBenchActQuestion < ActiveRecord::Base
  include PublicPersona
  belongs_to :act_bench
  belongs_to :act_question
  
  has_many :act_benches
  has_many :act_questions
   
  acts_as_list :scope => :act_question

end
