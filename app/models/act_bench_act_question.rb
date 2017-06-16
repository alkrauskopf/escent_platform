class ActBenchActQuestion < ActiveRecord::Base
  include PublicPersona
  belongs_to :act_bench
  belongs_to :act_question
  
  has_many :act_benches
  has_many :act_questions
   
  acts_as_list :scope => :act_question

  def self.for_bench(bench)
    where('act_bench_id = ?', bench.id )
  end

  def self.for_question(question)
    where('act_question_id = ?', question.id )
  end
end
