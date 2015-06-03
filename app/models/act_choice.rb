class ActChoice < ActiveRecord::Base


  include PublicPersona

  belongs_to :act_question
  
  has_many :act_answers
  
  validates_presence_of :choice


  named_scope :incorrect, :conditions => { :is_correct => false }
  named_scope :correct, :conditions => { :is_correct => true }  
  
end
