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

end
