class SurveySchedule < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :entity, :polymorphic => true
  belongs_to :user
  belongs_to :organization
  belongs_to :subject_area
  belongs_to :tlt_survey_audience
  belongs_to :tlt_survey_type
  belongs_to :survey_instruction
    
  has_many    :tlt_survey_responses, :dependent => :destroy
  has_many    :respondants, :through => :tlt_survey_responses, :source => :user, :uniq => true  
  has_many    :survey_schedule_takers, :dependent => :destroy
  has_many    :takers, :through => :survey_schedule_takers
  
  scope :active, :conditions => ["is_active = ?", true]
  scope :suspended, :conditions => ["!is_active"]
  scope :classroom, :conditions => ["entity_type = ? ", "ClassroomPeriod"], :order => "schedule_start DESC"
  scope :itl, :conditions => ["entity_type = ? ", "TltSession"], :order => "schedule_start DESC"
  scope :pd, :conditions => ["entity_type = ? ", "UserDlePlan"], :order => "schedule_start DESC"
  scope :app, :conditions => ["entity_type = ? ", "CoopApp"], :order => "schedule_start DESC"
  scope :for_audience, lambda{|audience| {:conditions => ["tlt_survey_audience_id = ? ", audience.id]}}
  scope :for_type, lambda{|s_type| {:conditions => ["tlt_survey_type_id = ? ", s_type.id]}}
  scope :for_class, lambda{|s_class| {:conditions => ["entity_type = ? ", s_class]}}
  scope :for_organization, lambda{|org| {:conditions => ["organization_id = ? ", org.id], :order => "schedule_start DESC"}}
  scope :broadcasted, :conditions => ["max_responses > ?", 1], :order => "schedule_start DESC"
  scope :self_survey, :conditions => ["max_responses = ?", 1], :order => "schedule_start DESC"
  scope :by_date, :order => "schedule_start DESC"

  def notify?
        self.is_notify
  end
  
  def anonymous?
        self.is_anon
  end

  def default_notify?
        default = SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
        default.nil? ? false : default.is_notify
  end
  
  def default_anonymous?
        default = SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
        default.nil? ? false : default.is_anon
  end

  def survey_instruction
      SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
  end

  def instructions
      default = SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
      default.nil? ? "" : default.instructions
  end

  def default_max_responses
      default = SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
      default.nil? ? 0 : default.max_responses
  end

  def default_duration
      default = SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
      default.nil? ? 0 : default.default_days
  end

  def subject_line
      default = SurveyInstruction.for_type(self.tlt_survey_type).for_audience(self.tlt_survey_audience).first rescue nil
      default.nil? ? "Survey" : default.subject_line
  end

  def de_activate
      self.update_attribute("is_active", false)
      self.takers.delete_all
  end  

#  def respondants
#     self.tlt_survey_responses.collect{|r| r.user}.compact.flatten.uniq.sort_by{|u| u.last_name}
#  end
   
  def question_responses
      self.tlt_survey_responses.sort_by{|r| r.created_at}
  end

  def responses_to_question(question, score)
      responses = score.nil? ? self.tlt_survey_responses.for_question(question) : self.tlt_survey_responses.for_question(question).select{|r| r.score == score}
  end

  def questions
      self.tlt_survey_responses.collect{|r| r.tlt_survey_question}.flatten.uniq.sort_by{|q| q.position}
  end



  def display_label
    label=""
    if self.entity.class.to_s == "ClassroomPeriod" 
      label = self.entity.classroom.course_name 
    end 
    if self.entity.class.to_s == "TltSession" 
      label = self.tlt_survey_type.coop_app.abbrev
    end        
    if self.entity.class.to_s == "UserDlePlan" 
      label = self.tlt_survey_type.coop_app.abbrev 
    end       
    if self.entity.class.to_s == "TltDiagnostic" 
      label = self.tlt_survey_type.coop_app.abbrev + " Reflection" 
    end 
     if self.entity.class.to_s == "CoopApp"
      label = self.entity.abbrev
    end
     if self.entity.class.to_s == "EltCycle"
      label = self.entity.name
    end
    label
  end

  def audience_type_label
    self.tlt_survey_type.name.titleize + " Survey For " + self.tlt_survey_audience.audience.titleize
  end

  def audience_name
    self.tlt_survey_audience.audience.titleize
  end

  def type_name
    self.tlt_survey_type.name.titleize
  end

  def identify_takers
    takers = 1
    if self.tlt_survey_audience.coop_app == CoopApp.classroom
      if self.tlt_survey_audience.audience == "teacher"
        self.takers << self.entity.teachers
        elsif self.tlt_survey_audience.audience == "student"
          self.takers << self.entity.students
        end
        takers = self.takers.size
    elsif self.tlt_survey_audience.coop_app == CoopApp.itl && self.entity.class.to_s == "TltSession"
      if self.tlt_survey_audience.audience == "teacher"
        self.takers << self.entity.user
        elsif self.tlt_survey_audience.audience == "observer"
          self.takers << self.entity.tracker
          elsif self.tlt_survey_audience.audience == "student"
            self.takers << self.entity.classroom_period.students
        end
        takers = self.takers.size
    elsif self.tlt_survey_audience.coop_app == CoopApp.itl && self.entity.class.to_s == "CoopApp"
      if self.tlt_survey_audience.audience == "teacher"
        self.takers << self.organization.teachers     
      end
      takers = self.takers.size
    elsif self.tlt_survey_audience.coop_app == CoopApp.elt && self.entity.class.to_s == "EltCycle"
      if self.tlt_survey_audience.audience == "client school"
        self.takers << self.entity.schools.collect{|s| s.elt_team}.flatten.uniq     
#       self.takers << self.entity.organization.elt_reviewers          
      end
      takers = self.takers.size
    end
    self.update_attribute("recipients", takers)
  end

end
