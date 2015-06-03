class ActRelReading < ActiveRecord::Base

  include PublicPersona


  belongs_to :act_subject
  belongs_to :user
  belongs_to :organization
  belongs_to :act_genre
  
  has_many   :act_questions   

  has_many :act_rel_reading_act_score_ranges, :dependent => :destroy
  has_many :act_score_ranges, :through => :act_rel_reading_act_score_ranges   
  
  
  validates_presence_of :act_subject_id
  validates_presence_of :label
  validates_presence_of :act_genre_id
  validates_length_of :reading, :within => 5..60000, :message => 'Invalid Length Of Reading'  
  
  def score_range(std)
    self.act_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
  end

  def score_range_name(std)
    score_range = self.act_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil  
    if score_range
      name = score_range.range
    else
      name = "No Mastery Level"
    end
  end
end
