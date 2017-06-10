class ActChoice < ActiveRecord::Base


  include PublicPersona

  belongs_to :act_question
  
  has_many :act_answers
  
  validates_presence_of :choice
  validates_numericality_of :position, :greater_than_or_equal_to => 1, :message => ' Must Be Greater Than Zero'


  scope :incorrect, :conditions => { :is_correct => false }
  scope :correct, :conditions => { :is_correct => true }


  def self.by_position
    order('position ASC')
  end

  def self.active
    where('is_active').by_position
  end

  def active?
    self.is_active
  end

  def inactive?
    !self.is_active
  end

  def destroyable?
    self.act_answers.empty? && self.inactive?
  end

  def correct?
    self.is_correct
  end


end
