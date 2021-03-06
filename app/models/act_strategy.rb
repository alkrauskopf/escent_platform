class ActStrategy < ActiveRecord::Base
  attr_accessible :act_subject_id, :description, :is_active, :name, :pos, :is_default

  belongs_to :act_subject

  has_many :act_questions
  has_many :act_answers
  has_many :act_strategy_logs

  validates_presence_of :act_subject_id,  :message => 'Subject Must Be Defined'
  validates_presence_of :name,  :message => 'Must Have Name'

  def active?
    self.is_active
  end

  def self.active
    where('is_active').order('pos ASC')
  end

  def default?
    self.is_default
  end

  def self.default
    where('is_default').first rescue nil
  end

  def self.by_position
    order('pos ASC')
  end

  def destroyable?
    self.act_answers.empty? && self.act_questions.enabled.empty?
  end

  def self.subjects
    where('is_active').map{|s| s.act_subject}.compact.uniq rescue []
  end

  def self.with_name(name)
    where('name = ?', name)
  end

end
