class IstaCase < ActiveRecord::Base

  include PublicPersona
  
  belongs_to :ista_step
  belongs_to :organization
  belongs_to :user

  has_many   :ista_case_allocations


  validates_presence_of :title
  validates_numericality_of :case_students, :greater_than_or_equal_to => 0, :message => ' Must Be Zero Or Greater' 
  validates_numericality_of :case_teachers, :greater_than_or_equal_to => 0.0, :message => ' Must Be Zero Or Greater' 


  named_scope :active, :conditions => ["is_active"], :order => 'final_date DESC'
  named_scope :final, :conditions => ["is_final"], :order => 'final_date DESC'
  named_scope :archived, :conditions => ["is_archived"], :order => 'final_date DESC'
  named_scope :open, :conditions => ["!is_final"], :order => 'created_at DESC'
  named_scope :last_first, :order => 'created_at DESC'
  
  def final?
    self.is_final
  end

  def total_std_minutes_week
    (self.daysweek * self.hrsday_std) > 0 ? (self.daysweek * self.hrsday_std * 60.0).to_i : 1
  end
  
  def total_hours_year
    (self.hrsday_er * self.daysyear_er) + (self.hrsday_ls * self.daysyear_ls) + (self.daysyear_std * self.hrsday_std)
  end

  
  def total_school_students
    self.organization.time_allocation.total_students
  end
  
  def total_school_teachers
    self.organization.time_allocation.fte_teacher
  end
  
  def student_pct
    self.organization.time_allocation.total_students > 0 ? self.case_students.to_f/self.organization.time_allocation.total_students.to_f : 0.0
  end

  def teacher_pct
    self.organization.time_allocation.fte_teacher > 0 ? self.case_teachers.to_f/self.organization.time_allocation.fte_teacher : 0.0
  end
 
  def step_2_minutes_week_total
    self.ista_case_allocations.for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def academics_minutes_week_classes
    self.ista_case_allocations.for_group(IstaGroup.academics[0]).for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def academics_minutes_week_classes_pct
    100.0*self.academics_minutes_week_classes.to_f/self.total_std_minutes_week.to_f
  end
  
  def academics_minutes_week_support
    self.ista_case_allocations.for_group(IstaGroup.academics[1]).for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def academics_minutes_week_support_pct
    100.0*self.academics_minutes_week_support.to_f/self.total_std_minutes_week.to_f
  end


  def electives_minutes_week_total
    self.electives_minutes_week_classes + self.electives_minutes_week_support
  end
  
  def electives_minutes_week_classes
    self.ista_case_allocations.for_group(IstaGroup.electives[0]).for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def electives_minutes_week_classes_pct
    100.0*self.electives_minutes_week_classes.to_f/self.total_std_minutes_week.to_f
  end
  
  def electives_minutes_week_support
    self.ista_case_allocations.for_group(IstaGroup.electives[1]).for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def electives_minutes_week_support_pct
    100.0*self.electives_minutes_week_support.to_f/self.total_std_minutes_week.to_f
  end
 

  def other_minutes_week_total
    self.other_minutes_week_classes + self.other_minutes_week_support
  end
  
  def other_minutes_week_classes
    self.ista_case_allocations.for_group(IstaGroup.other[0]).for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def other_minutes_week_classes_pct
    100.0*self.electives_minutes_week_classes.to_f/self.total_std_minutes_week.to_f
  end
  
  def other_minutes_week_support
    self.ista_case_allocations.for_group(IstaGroup.other[1]).for_step(IstaStep.step_2.first).collect{|a| a.minsweek}.sum
  end
  
  def other_minutes_week_support_pct
    100.0*self.other_minutes_week_support.to_f/self.total_std_minutes_week.to_f
  end 

  def academics_minutes_week_total
    self.academics_minutes_week_classes + self.academics_minutes_week_support
  end
  
  def academics_weekly_total_pct
    100.0*self.academics_minutes_week_total.to_f/self.total_std_minutes_week.to_f
  end

  def electives_minutes_week_total
    self.electives_minutes_week_classes + self.electives_minutes_week_support
  end
  
  def electives_weekly_total_pct
    100.0*self.electives_minutes_week_total.to_f/self.total_std_minutes_week.to_f
  end

  def other_minutes_week_total
    self.other_minutes_week_classes + self.other_minutes_week_support
  end
  
  def other_weekly_total_pct
    100.0*self.other_minutes_week_total.to_f/self.total_std_minutes_week.to_f
  end

  def academics_hours_week_total
    self.academics_minutes_week_total.to_f/60.0
  end

  def electives_hours_week_total
    self.electives_minutes_week_total.to_f/60.0
  end

  def other_hours_week_total
    self.other_minutes_week_total.to_f/60.0
  end

  def academics_hours_day_total
    self.daysweek > 0 ? self.academics_hours_week_total/self.daysweek : self.academics_hours_week_total/5.0
  end

  def electives_hours_day_total
    self.daysweek > 0 ? self.electives_hours_week_total/self.daysweek : self.electives_hours_week_total/5.0
  end

  def other_hours_day_total
    self.daysweek > 0 ? self.other_hours_week_total/self.daysweek : self.other_hours_week_total/5.0
  end 
  
  def academics_minutes_week_nonpurposed
    self.ista_case_allocations.for_group(IstaGroup.academics[0]).for_step(IstaStep.step_3.first).collect{|a| a.minsweek}.sum   + self.ista_case_allocations.for_group(IstaGroup.academics[1]).for_step(IstaStep.step_3.first).collect{|a| a.minsweek}.sum 
  end
  
  def academics_minutes_week_nonpurposed_pct
    100.0*self.academics_minutes_week_nonpurposed.to_f/self.total_std_minutes_week.to_f
  end
  
  def electives_minutes_week_nonpurposed
    self.ista_case_allocations.for_group(IstaGroup.electives[0]).for_step(IstaStep.step_3.first).collect{|a| a.minsweek}.sum   + self.ista_case_allocations.for_group(IstaGroup.electives[1]).for_step(IstaStep.step_3.first).collect{|a| a.minsweek}.sum 
  end
  
  def electives_minutes_week_nonpurposed_pct
    100.0*self.electives_minutes_week_nonpurposed.to_f/self.total_std_minutes_week.to_f
  end
  
  def other_minutes_week_nonpurposed
    self.academics_minutes_week_nonpurposed + electives_minutes_week_nonpurposed
  end
  
  def other_minutes_week_nonpurposed_pct
    100.0*self.other_minutes_week_nonpurposed.to_f/self.total_std_minutes_week.to_f
  end
  
  def academics_minutes_week_actual
    self.academics_minutes_week_total - self.academics_minutes_week_nonpurposed 
  end
  
  def electives_minutes_week_actual
    self.electives_minutes_week_total - self.electives_minutes_week_nonpurposed 
  end 
  
  def other_minutes_week_actual
    self.other_minutes_week_total + self.other_minutes_week_nonpurposed
  end

  
  def academics_minutes_week_actual_pct
    100.0*self.academics_minutes_week_actual.to_f/self.total_std_minutes_week.to_f 
  end
  
  def electives_minutes_week_actual_pct
    100.0*self.electives_minutes_week_actual.to_f/self.total_std_minutes_week.to_f 
  end  
  
  def other_minutes_week_actual_pct
    100.0*self.other_minutes_week_actual.to_f/self.total_std_minutes_week.to_f 
  end        

  def academics_hours_year
    749 
  end
   
  def academics_hours_year_pct
    100.0*self.academics_hours_year.to_f/self.total_hours_year.to_f 
  end

  def electives_hours_year
    66
  end
   
  def electives_hours_year_pct
    100.0*self.electives_hours_year.to_f/self.total_hours_year.to_f 
  end

  def other_hours_year
    400
  end
   
  def other_hours_year_pct
    100.0*self.other_hours_year.to_f/self.total_hours_year.to_f 
  end
    
  def electives_hours_year_redirected
    self.ista_case_allocations.for_group(IstaGroup.electives[0]).for_step(IstaStep.step_4.first).collect{|a| a.hrsyear}.sum   + self.ista_case_allocations.for_group(IstaGroup.electives[1]).for_step(IstaStep.step_4.first).collect{|a| a.hrsyear}.sum 
  end
      
  def electives_hours_year_redirected_pct
    100.0*self.electives_hours_year_redirected.to_f/self.total_hours_year.to_f
  end
      
  def electives_est_annual_redirected
    67
  end
      
  def electives_est_annual_redirected_pct
    100.0*self.electives_est_annual_redirected.to_f/self.total_hours_year.to_f
  end  
    
  def other_hours_year_redirected
    self.ista_case_allocations.for_group(IstaGroup.other[0]).for_step(IstaStep.step_4.first).collect{|a| a.hrsyear}.sum   + self.ista_case_allocations.for_group(IstaGroup.other[1]).for_step(IstaStep.step_4.first).collect{|a| a.hrsyear}.sum 
  end
      
  def other_hours_year_redirected_pct
    100.0*self.other_hours_year_redirected.to_f/self.total_hours_year.to_f
  end
      
  def other_est_annual_redirected
    276
  end
      
  def other_est_annual_redirected_pct
    100.0*self.other_est_annual_redirected.to_f/self.total_hours_year.to_f
  end

  def student_academics_hrs_week_total
    (self.academics_minutes_week_total.to_f * self.case_students.to_f) /60.0
  end

  def student_electives_hrs_week_total
    (self.electives_minutes_week_total.to_f * self.case_students.to_f) /60.0
  end

  def student_other_hrs_week_total
    (self.other_minutes_week_total.to_f * self.case_students.to_f) /60.0
  end

  def student_academics_hrs_week_actual
    (self.academics_minutes_week_actual.to_f * self.case_students.to_f) /60.0
  end

  def student_electives_hrs_week_actual
    (self.electives_minutes_week_actual.to_f * self.case_students.to_f) /60.0
  end

  def student_other_hrs_week_actual
    (self.other_minutes_week_actual.to_f * self.case_students.to_f) /60.0
  end

  
  def student_academics_hrs_week_nonpurposed
    (self.academics_minutes_week_nonpurposed.to_f * self.case_students.to_f) /60.0  
  end
  
  def student_electives_hrs_week_nonpurposed
    (self.electives_minutes_week_nonpurposed.to_f * self.case_students.to_f) /60.0  
  end
  
  def student_other_hrs_week_nonpurposed
    (self.other_minutes_week_nonpurposed.to_f * self.case_students.to_f) /60.0  
  end
  
  def teacher_academics_student_hrs_total
    self.case_teachers > 0.0 ? self.student_academics_hrs_week_total.to_f/self.case_teachers : 0.0
  end

  def teacher_electives_student_hrs_total
    self.case_teachers > 0.0 ? self.student_electives_hrs_week_total.to_f/self.case_teachers : 0.0
  end

  def teacher_academics_student_hrs_actual
    self.case_teachers > 0.0 ? self.student_academics_hrs_week_actual.to_f/self.case_teachers : 0.0
  end

  def teacher_electives_student_hrs_actual
    self.case_teachers > 0.0 ? self.student_electives_hrs_week_actual.to_f/self.case_teachers : 0.0
  end  

  def teacher_other_student_hrs_actual
    self.case_teachers > 0.0 ? self.student_other_hrs_week_actual.to_f/self.case_teachers : 0.0
  end

  
  def teacher_academics_student_hrs_nonpurposed
    self.case_teachers > 0.0 ? self.student_academics_hrs_week_nonpurposed.to_f/self.case_teachers : 0.0
  end

  def teacher_electives_student_hrs_nonpurposed
    self.case_teachers > 0.0 ? self.student_electives_hrs_week_nonpurposed.to_f/self.case_teachers : 0.0
  end

  def teacher_other_student_hrs_nonpurposed
    self.case_teachers > 0.0 ? self.student_other_hrs_week_nonpurposed.to_f/self.case_teachers : 0.0
  end

end
