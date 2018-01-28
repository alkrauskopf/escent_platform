class ActStrategyLog < ActiveRecord::Base
  attr_accessible :act_assessment_id, :act_strategy_id, :act_submission_id, :classroom_id, :organization_id, :preferred,
                  :mis_matches, :incorrects, :matches, :corrects, :user_id, :act_subject_id, :period_end

  belongs_to :act_assessment
  belongs_to :act_strategy
  belongs_to :act_submission
  belongs_to :classroom
  belongs_to :organization
  belongs_to :user
  belongs_to :act_subject

  def self.for_strategy(strategy)
    where('act_strategy_id = ?', strategy.id).order('created_at DESC')
  end

  def self.for_subject(subject)
    where('act_subject_id = ?', subject.id).order('created_at DESC')
  end

  def self.default(strategy)
    where('act_strategy_id = ?', strategy.id).first rescue nil
  end

  def use_count
    self.matches + self.mis_matches
  end

end
