class FolderMasteryLevel < ActiveRecord::Base

  belongs_to :act_score_range
  belongs_to :folder

  has_many :folders
  has_many :act_score_ranges

  scope :for_level, lambda{|mastery| {:conditions => ["act_score_range_id = ? ", mastery.id]}}

end
