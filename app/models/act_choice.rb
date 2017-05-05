class ActChoice < ActiveRecord::Base


  include PublicPersona

  belongs_to :act_question
  
  has_many :act_answers
  
  validates_presence_of :choice


  scope :incorrect, :conditions => { :is_correct => false }
  scope :correct, :conditions => { :is_correct => true }


  def self.by_position
    order('position ASC')
  end

end
