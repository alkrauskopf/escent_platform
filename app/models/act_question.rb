class ActQuestion < ActiveRecord::Base

  include PublicPersona
  acts_as_tree

  has_attached_file :question_image,
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename",
                    :styles => { :thumb => "118x166#", :small_thumb => "59x83#", :assessment => "140x140#" }
  validates_attachment :question_image,
                       content_type: {content_type: ['image/gif', 'image/jpeg', 'image/png', 'image/pjpeg', 'image/x-png']}
  validates_with AttachmentSizeValidator, attributes: :question_image, less_than: 5.megabytes



  has_many  :act_choices, :dependent => :destroy
  has_one  :act_question_reading, :dependent => :destroy

  belongs_to :mastery_level, :class_name => 'ActScoreRange', :foreign_key => "act_score_range_id"
  belongs_to :strand, :class_name => 'ActStandard', :foreign_key => "act_standard_id"
  belongs_to :act_subject
  belongs_to :user
  belongs_to :organization
  belongs_to :content
  belongs_to :act_rel_reading
  belongs_to :co_grade_level
  belongs_to :act_strategy


  has_many :act_assessment_act_questions, :dependent => :destroy
  has_many :act_assessments, :through => :act_assessment_act_questions, :order => "position"    
  has_many :act_answers
  has_many :ifa_student_levels
 
  has_many :act_bench_act_questions, :dependent => :destroy
  has_many :act_benches, :through => :act_bench_act_questions  
  has_many :act_question_act_score_ranges, :dependent => :destroy
  has_many :act_score_ranges, :through => :act_question_act_score_ranges  
  has_many :act_question_act_standards, :dependent => :destroy
  has_many :act_standards, :through => :act_question_act_standards  
  has_many :ifa_question_logs
  has_many :ifa_question_performances

  before_save :before_save_method
  before_create :before_create_method

  validates_presence_of :act_subject_id
  validates_presence_of :act_score_range_id,  :message => 'Must Define Mastery Level'
  validates_presence_of :act_standard_id,  :message => 'Must Define Knowledge Strand'
  validates_presence_of :question_type, :message => ': SELECT ANSWER TYPE'
  validates_length_of :question, :within => 1..25500, :message => 'Invalid Length Of Question'  

  scope :unlocked, :conditions => { :is_locked => false }
  scope :lock, :conditions => { :is_locked => true }
  scope :calibrated, :conditions => { :is_calibrated => true }
  scope :not_calibrated, :conditions => { :is_calibrated => false }
  scope :for_subject, lambda{|subject| {:conditions => ["act_subject_id = ? ", subject.id]}}
  scope :for_mastery_level, lambda{|mstr| {:conditions => ["act_score_range_id = ? ", mstr.id]}}
  scope :using_reading, lambda{|reading| {:conditions => ["act_rel_reading_id = ? ", reading.id]}}
  scope :active, :conditions => { :is_active => true }
  scope :available_for_user, lambda{|user| {:conditions => ["(is_active AND is_locked) OR user_id = ? ", user.id]}}
  scope :since, lambda{| begin_date| {:conditions => ["created_at >= ?", begin_date]}}
  scope :until, lambda{| end_date| {:conditions => ["created_at <= ?", end_date]}}
  scope :for_teacher, lambda{| teacher| {:conditions => ["teacher_id = ?", teacher.id]}}
  
  scope :available, {:conditions => ["is_active = true && is_locked = true"]}

  TYPES = [
      [ "Multiple Choice", "MC" ],
      [ "Short Answer", "SA" ]
  ]

  def self.with_strategy(strategy)
    where('act_strategy_id = ?', strategy.id)
  end

  def self.creators
    ActQuestion.all.collect{|q| q.user}.compact.uniq.sort_by{|u| u.last_name}
  end

  def self.untagged
    ActQuestion.all.select{|q| q.mastery_level.nil? || q.strand.nil?}
  end

  def self.mc
    where('question_type = ?', 'MC')
  end

  def self.sa
    where('question_type = ?', 'SA')
  end

  def self.by_date
    order('updated_at DESC')
  end

  def active?
    self.is_active
  end

  def locked?
    self.is_locked
  end

  def moveable?
    self.calibrated?
  end

  def self.for_test
    where('is_active')
  end

  def unassign_benchmarks
    self.act_bench_act_questions.destroy_all
  end

  def correct_choices
    self.act_choices.correct
  end

  def self.enabled
    where('is_active')
  end

  def self.for_level(level)
    level.nil? ? [] : where('act_score_range_id = ?', level.id)
  end

  def assessment_count
    self.act_assessments.size
  end
  def benchmark_count
    self.act_benches.size
  end

  def self.for_strand(strand)
    strand.nil? ? [] : where('act_standard_id = ?', strand.id)
  end

  def self.all_for_level_strand(level, strand)
    (!strand.nil? && !level.nil?) ?  where('act_standard_id = ? && act_score_range_id = ?', strand.id, level.id) : []
  end

  def self.enabled_for_level_strand(level, strand)
    (!strand.nil? && !level.nil?) ?  where('act_standard_id = ? && act_score_range_id = ? && is_active', strand.id, level.id) : []
  end

  def self.for_user(user)
    user.nil? ? [] : where('user_id = ?', user.id)
  end

  def destroyable?
    self.act_assessments.lock.empty? && !self.active?
  end

  def editable?
    self.act_choices.empty?
  end

  def enableable?
    self.short_answer? || !self.choices.empty? || true
  end

  def image_enlarge?
    self.is_enlarged
  end

  def reading?
    self.act_rel_reading ? true : false
  end

  def reading
    self.act_rel_reading
  end

  def reading_genre
    (self.reading? && self.reading.act_genre) ? self.reading.act_genre.name : 'None'
  end

  def multiple_choice?
    self.question_type == 'MC'
  end

  def short_answer?
    self.question_type == 'SA'
  end

  def of_mastery_level?(level)
    self.act_score_ranges.include?(level)
  end

  def of_strand?(strand)
    self.act_standards.include?(strand)
  end

  def calculator_free?
    self.is_calc_free
  end

  def randomize?
    self.is_random
  end

  def calibrated?
    self.is_calibrated
  end

  def choices
    choices = self.randomize? ? self.act_choices.active.shuffle : self.act_choices.active.by_position
  end

  def all_choices
    self.act_choices.by_position
  end
  def score_range(std)
    self.act_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
  end

  def score_range_name(std)
    score = self.act_score_ranges.select{|r| r.act_master_id == std.id}.first rescue nil
    if score
      name = score.range
    else
      name = "No Level"
    end
  end

  def benchmarks
    self.act_benches.active.select{|b| b.benchmark?}
  end
  def all_benchmarks
    self.act_benches
  end

  def strands
    self.act_standards.active
  end

  def levels
    self.act_score_ranges.no_na.active
  end

  def assessments
    self.act_assessments.active
  end

  def all_assessments
    self.act_assessments
  end

  def strand_remove(strand)
    self.act_question_act_standards.for_strand(strand).destroy_all
  end

  def level_remove(level)
    self.act_question_act_score_ranges.for_mastery_level(level).destroy_all
  end

  def assessment_remove(assessment)
    self.act_assessment_act_questions.for_assessment(assessment).destroy_all
  end

  def standard(std)
    self.act_standards.select{|s| s.act_master_id == std.id}.first rescue nil
  end

  def standard_abbrev(std)
    stand = self.act_standards.select{|s| s.act_master_id == std.id}.first rescue nil
    if stand
      abbrev = stand.abbrev.upcase
    else
      abbrev = "No Knowledge Strand"
    end
  end

  def upper_score(std)
    q_score_range = self.score_range(std)rescue nil
    if q_score_range
      score = q_score_range.upper_score
    else
      score = 0
    end
  end

  def lower_score(std)
    q_score_range = self.score_range(std)rescue nil
    if q_score_range
      score = q_score_range.lower_score
    else
      score = 0
    end
  end

  def calibrate_assessments
    self.act_assessments.each do |ass|
      ass.calibrate
    end
  end
 

  def last_date_changed
    last_changed = self.updated_at
    self.act_choices.each do |c|
      last_changed = c.updated_at > last_changed ? c.updated_at : last_changed
    end
    if self.act_question_reading
      last_changed = self.act_question_reading.updated_at > last_changed ? self.act_question_reading.updated_at : last_changed
    end
  last_changed
  end 
  
  def sequence_score_for(std, filter)

    subject_ranges = std.act_score_ranges.for_subject(self.act_subject).no_na
    q_performances = self.ifa_question_performances.select{|qp| subject_ranges.include?(qp.act_score_range)}.sort_by{|p| [p.act_score_range.upper_score]} rescue[]
    prof_array = Array.new

    q_performances.each do |perf|
       if filter.upcase == "CAL"
         prof = perf.calibrated_student_answers > 0 ? (100*perf.calibrated_student_points.to_f/perf.calibrated_student_answers.to_f) : 999.0
       end
       if filter.upcase == "ACT"
         prof = perf.baseline_answers > 0 ? (100*perf.baseline_points.to_f/perf.baseline_answers.to_f) : 999.0
       end
       if filter.upcase == "PP"
         prof = perf.baseline_answers > 0 ? (100*perf.baseline_points.to_f/perf.baseline_answers.to_f) : 999.0
       end
       if filter.upcase == "ALL"
         prof = perf.answers > 0 ? (100*perf.points.to_f/perf.answers.to_f) : 999.0
       end
       unless prof == 999.0
         prof_array << prof
       end
    end
    score = 0
    sequences = prof_array.count - 1
    prof_array.each_with_index do |p,idx|
      unless (idx) >= sequences
        score = p <= prof_array[idx+1] ? score + 1 : score
      end  
    end
    seq_score = sequences > 0 ? (100*score.to_f/ sequences.to_f).round : nil

  end 

  def alignment_score_for(std, filter)
    q_range = self.act_score_ranges.for_standard(std).first rescue nil
    good_alignment_count = 0
    alignment_checks = 0
    unless q_range.nil?
      subject_ranges = std.act_score_ranges.for_subject(self.act_subject).no_na.sort_by{|r| [r.upper_score]}
      q_range_index = subject_ranges.index(q_range)
      if q_range_index
        subject_ranges.each_with_index do |range,idx|
        prof_delta = (idx < q_range_index) ? (idx - q_range_index)*5 : (idx - q_range_index)*3
        perf = self.ifa_question_performances.for_range(range).first rescue nil
        unless perf.nil?
# Calculate proficiency of student group
           if filter == "CAL"
             prof = perf.calibrated_student_answers > 0 ? (100*perf.calibrated_student_points.to_f/perf.calibrated_student_answers.to_f) : 999.0
           end
           if filter == "ACT"
             prof = perf.baseline_answers > 0 ? (100*perf.baseline_points.to_f/perf.baseline_answers.to_f) : 999.0
           end
           if filter == "PP"
             prof = perf.baseline_answers > 0 ? (100*perf.baseline_points.to_f/perf.baseline_answers.to_f) : 999.0
           end
           if filter == "ALL"
             prof = perf.answers > 0 ? (100*perf.points.to_f/perf.answers.to_f)  : 999.0
           end
          unless prof == 999.0
            alignment_checks += 1
            if idx < q_range_index
#    Proficiencies should be below expectation
              good_alignment_count = prof.to_i <= (80 + prof_delta) ? good_alignment_count + 1 : good_alignment_count
            elsif
#    Proficiencies should be at or above expectation              
              good_alignment_count = prof.to_i >= (80 + prof_delta) ? good_alignment_count + 1 : good_alignment_count
            end
          end
        end
      end
      end
    end
   align_score = alignment_checks > 0 ? (100*good_alignment_count.to_f/ alignment_checks.to_f).round : nil
#    align_score = q_range_index
  end

  private

  def before_create_method
    if !self.act_subject.nil? && self.allotted_time <= 0
      self.allotted_time = self.act_subject.question_time
    end
  end

  def before_save_method
    if self.act_strategy.nil? && !self.act_subject.nil? && !self.act_subject.act_strategies.default.nil?
      self.act_strategy_id = self.act_subject.act_strategies.default.id
    end
  end

  def picture_width
    required_width  = 300
    if question_image.queued_for_write[:original]
      dimensions = Paperclip::Geometry.from_file(picture.queued_for_write[:original].path)
      errors.add(:question_image, "Width can't be greater than #{required_width}") unless dimensions.width <= required_width
    end
  end
end
