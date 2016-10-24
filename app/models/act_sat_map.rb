class ActSatMap < ActiveRecord::Base
  attr_accessible :lower_score, :range, :upper_score

  has_one :act_score_range
end
