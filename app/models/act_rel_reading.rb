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
  validates_length_of :reading, :within => 5..60000, :message => 'Reading too small or too large.'
  
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

  def self.by_label
    self.order('label')
  end

  def self.by_genre
    self.includes(:act_subject, :act_genre).order('act_subjects.name ASC, act_genres.name ASC, label ASC')
  end

  def self.for_subject(subject)
    where('act_subject_id = ?', subject.id).includes(:act_genre).order('act_genres.name ASC, label ASC')
  end

  def genre
    self.act_genre
  end

  def subject
    self.act_subject
  end

  def destroyable?(user)
    self.act_questions.empty? && (user == self.user || user.ifa_admin_for_org?(self.organization))
  end

  def updateable?(user)
    user == self.user || user.ifa_admin_for_org?(self.organization)
  end

  def self.creators
    ActRelReading.all.map{|r| r.user}.compact.uniq.sort_by{|u| u.last_name}
  end

  def self.empties
    ActRelReadings.all.select{|r| r.act_questions.empty?}
  end

  def questions
    self.act_questions
  end

end
