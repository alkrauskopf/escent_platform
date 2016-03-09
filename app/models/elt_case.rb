class EltCase < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :organization
  belongs_to :user
  belongs_to :subject_area
  belongs_to :classroom
  belongs_to :grade_level
  belongs_to :elt_type
  belongs_to :reviewer, :class_name => 'User', :foreign_key => "reviewer_id"
  belongs_to :elt_cycle


  has_many :elt_case_notes, :dependent => :destroy
  has_many :elt_case_indicators, :dependent => :destroy

  validates_presence_of :name
 
  named_scope :submitted, :conditions => ["is_submitted"], :order => 'submit_date DESC'
  named_scope :final, :conditions => ["is_final"], :order => 'finalize_date DESC'
  named_scope :last_first, :order => 'created_at DESC'
  named_scope :for_subject, lambda{|subject| {:conditions => ["subject_area_id = ? ", subject.id], :order => "submit_date DESC"}}
  named_scope :for_grade, lambda{|grade| {:conditions => ["grade_level_id = ? ", grade.id], :order => "submit_date DESC"}}
  named_scope :for_activity, lambda{|activity| {:conditions => ["elt_type_id = ? ", activity.id], :order => "submit_date DESC"}}
  named_scope :for_cycle, lambda{|cycle| {:conditions => ["elt_cycle_id = ? ", cycle.id], :order => "submit_date DESC"}}
  named_scope :for_other_cycles, lambda{|cycle| {:conditions => ["elt_cycle_id != ? ", cycle.id], :order => "submit_date DESC"}}

  named_scope :for_provider, lambda{|provider| {:include => :elt_cycle, :conditions => ["elt_cycles.organization_id = ?", provider.id], :order => "submit_date DESC"}}
  named_scope :for_framework, lambda{|framework| {:include => :elt_cycle, :conditions => ["elt_cycles.elt_framework_id = ?", framework.id], :order => "submit_date DESC"}}

  def framework
    self.elt_type.elt_framework rescue nil
  end

  def activity
    self.elt_type rescue nil
  end

  def provider
    self.elt_cycle ? self.elt_cycle.provider : nil
  end

  def elements
    self.elt_case_indicators.collect{ |ci| ci.elt_element}.flatten.compact.uniq.sort_by{ |e| e.position }
  end

  def element_indicators(element)
    self.elt_case_indicators.for_element(element).collect{ |ci| ci.elt_indicator }.compact.sort_by{|i| i.position}
  end

  def element_findings(element)
    self.elt_case_indicators.for_element(element)
  end

  def self.schools_for_provider(provider)
    EltCase.for_provider(provider).collect{|c| c.organization}.compact.flatten.uniq.sort_by{|o| o.name}
  end

  def case_indicator(elt_indicator)
    indicator = self.elt_case_indicators.for_indicator(elt_indicator).empty? ? nil : self.elt_case_indicators.for_indicator(elt_indicator).first
  end

  def rubric_for_indicator(indicator)
    (self.case_indicator(indicator).nil? || !self.case_indicator(indicator).rubric) ? nil : self.case_indicator(indicator).rubric
  end

  def note_for_indicator(indicator)
    self.case_indicator(indicator).nil? ? "" : self.case_indicator(indicator).note
  end
  
  def element_note(elt_element)
    note = self.elt_case_notes.for_element(elt_element).empty? ? nil : self.elt_case_notes.for_element(elt_element).first
  end


  def cycle_case_indicators_for_element(element)
    self.organization.elt_cases.for_cycle(self.elt_cycle).collect{|c| c.elt_case_indicators.for_element(element)}.compact.flatten
  end

  def cycle_ratings_for_element(element)
    self.cycle_case_indicators_for_element(element).collect{|ci| ci.rubric}.compact
  end

  def element_rubric_count(elt_element, rubric)
    self.elt_case_indicators.for_element_rubric(elt_element, rubric).count
  end

  def case_indicators_for(element, rubric)
    note = self.elt_case_indicators.for_rubric(rubric).select{|i| i.elt_indicator.elt_element_id == element.id}.sort_by{|i| i.elt_indicator.position}
  end

  def scores_for(element)
    self.elt_case_indicators.for_element(element).collect{ |i| i.score }
  end

  def submitted?
    self.is_submitted
  end

  def final?
    self.is_final
  end

  def master?
    self.elt_type ? self.elt_type.master? : false
  end

  def rubric?
    self.elt_type ? self.elt_type.rubric? : false
  end
    
  def updatable?(user)
    !self.final? && (self.user == user || user.elt_admin?(self.elt_cycle.organization))
  end
  
  def viewable?(user)
    (self.final? && self.elt_type.reportable?) || (self.user_id == user.id) || user.elt_reviewer?(self.elt_cycle.organization)
  end
  
  def deletable?(user)
    self.updatable?(user) || (!self.final? && user.elt_admin?(self.elt_cycle.organization))
  end

  def destroyable?(user)
    !self.final? && (user.elt_admin?(self.elt_cycle.organization) || user == self.user)
  end  
  
  def finalizable?(user)
    !self.final? && user.elt_reviewer?(self.elt_cycle.organization)
  end  
  
  def reopenable?(user)
    self.final? && user.elt_admin?(self.elt_cycle.organization)
  end 

  def completed?
    !self.elt_type.rubric? || self.elt_type.rubrics.active.empty? || self.elt_type.elt_indicators.active.collect{|i| i.elt_case_indicators.for_case(self).rated}.flatten.size == self.elt_type.elt_indicators.active.size
  end

  def indicators_rated
    self.elt_type.rubric? ? self.elt_type.elt_indicators.active.collect{|i| i.elt_case_indicators.for_case(self).rated}.flatten.size : 0
  end

  def findings
    if self.elt_type.rubric?
      self.indicators_rated
    else
      self.elt_case_indicators.with_note.flatten.size
    end
  end

  def rateable_indicators
    rateables = 0
    if self.elt_type.rubric?
     self.elt_type.active_elements.each do |element|
      rateables +=  element.elt_indicators.active.for_activity(self.elt_type).size
     end
    end
   rateables
  end

  def finalize_it
    unless self.final?
      if self.rubric? && self.elt_cycle
        self.elt_case_indicators.each do |case_indicator|
          unless case_indicator.score.nil? || !case_indicator.elt_indicator
            indicator = case_indicator.elt_indicator
            if self.elt_cycle.summary_for_indicator(indicator)
              self.elt_cycle.summary_for_indicator(indicator).update_attributes(:score_total => (self.elt_cycle.summary_for_indicator(indicator).score_total + case_indicator.score), :score_count => (self.elt_cycle.summary_for_indicator(indicator).score_count + 1))
            else
              summary_record = EltCycleSummary.new
              summary_record.elt_indicator_id = indicator.id
              summary_record.elt_type_id = self.elt_type_id
              summary_record.score_total = case_indicator.score
              summary_record.score_count = 1
              self.elt_cycle.elt_cycle_summaries << summary_record
            end
          end
        end
      end
      self.update_attributes(:is_final=> true, :finalize_date=>Date.today)
    end
  end

  def unfinalize_it
    if self.final?
      if self.rubric? && self.elt_cycle
        self.elt_case_indicators.each do |case_indicator|
          unless case_indicator.score.nil? || !case_indicator.elt_indicator
            indicator = case_indicator.elt_indicator
            if self.elt_cycle.summary_for_indicator(indicator) && self.elt_cycle.summary_for_indicator(indicator).score_count > 1
              self.elt_cycle.summary_for_indicator(indicator).update_attributes(:score_total => (self.elt_cycle.summary_for_indicator(indicator).score_total - case_indicator.score), :score_count => (self.elt_cycle.summary_for_indicator(indicator).score_count - 1))
            elsif self.elt_cycle.summary_for_indicator(indicator)
              self.elt_cycle.summary_for_indicator(indicator).destroy
            end
          end
        end
      end
      self.update_attributes(:is_final=> false, :finalize_date=>Date.today)
    end
  end

  def reassign_it(new_org_id, new_cycle_id)
    self.update_attributes(:organization_id => new_org_id, :elt_cycle_id => new_cycle_id)
  end
end
