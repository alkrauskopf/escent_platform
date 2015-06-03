class AddMoreFieldsToSesssionNSurvey < ActiveRecord::Migration
  def self.up
 
    add_column :tlt_sessions, :is_observer_done, :boolean
    add_column :tlt_sessions, :is_teacher_done, :boolean
    remove_column :tlt_sessions, :is_pending_review
    rename_column :tlt_sessions, :review_date, :observer_done_date
    add_column :tlt_sessions, :teacher_done_date, :date    
    rename_column :tlt_sessions, :coaching_point, :learning
    add_column :tlt_sessions, :next_step, :text
    
    add_column :tlt_survey_questions, :tlt_survey_audience_id, :integer
    add_column :tlt_survey_responses, :tlt_survey_audience_id, :integer

    execute "UPDATE tlt_sessions SET next_step = ''" 
    execute "UPDATE tlt_sessions SET is_observer_done = 0"    
    execute "UPDATE tlt_sessions SET is_teacher_done = 0" 
    execute "UPDATE tlt_survey_questions SET tlt_survey_audience_id = 1" 
    execute "UPDATE tlt_survey_responses SET tlt_survey_audience_id = 1"
  end

  def self.down
 
    remove_column :tlt_sessions, :is_observer_done, :boolean
    remove_column :tlt_sessions, :is_teacher_done, :boolean
    add_column :tlt_sessions, :is_pending_review; :boolean
    rename_column :tlt_sessions, :observer_done_date, :review_date
    remove_column :tlt_sessions, :teacher_done_date   
    rename_column :tlt_sessions, :learning, :coaching_point
    remove_column :tlt_sessions, :next_step
    remove_column :tlt_survey_questions, :tlt_survey_audience_id
    remove_column :tlt_survey_responses, :tlt_survey_audience_id
    
  end
end
