class ActSatMap < ActiveRecord::Base
  attr_accessible :lower_score, :range, :upper_score

  has_one :act_score_range

  def self.get_map(lower, upper)
    where('lower_score = ? && upper_score = ?', lower, upper).first rescue nil
  end

end
