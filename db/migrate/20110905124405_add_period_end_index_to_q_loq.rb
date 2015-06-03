class AddPeriodEndIndexToQLoq < ActiveRecord::Migration
  def self.up


  add_column :ifa_question_logs, :period_end, :date
    remove_index :ifa_question_logs, [:user_id, :act_subject_id, :is_calibrated, :date_taken]
    remove_index :ifa_question_logs, [:organization_id, :act_subject_id, :is_calibrated, :date_taken]
    remove_index :ifa_question_logs, [:classroom_id, :act_subject_id, :is_calibrated, :date_taken]
    remove_index :ifa_question_logs, [:teacher_id, :act_subject_id, :is_calibrated, :date_taken]
    remove_index :ifa_question_logs, [:act_assessment_id, :date_taken]
    remove_index :ifa_question_logs, [:act_submission_id]  
    add_index :ifa_question_logs, [:act_submission_id,:act_question_id] 
    add_index :ifa_question_logs, [:user_id, :act_subject_id, :period_end]    
    add_index :ifa_question_logs, [:organiztion_id, :act_subject_id, :period_end]
    add_index :ifa_question_logs, [:classroom_id, :act_subject_id, :period_end]    
    add_index :ifa_question_logs, [:act_question_id, :act_submission_id]    
  end

  def self.down
 

  remove_column :ifa_question_logs, :period_end
  
    add_index :ifa_question_logs, [:user_id, :act_subject_id, :is_calibrated, :date_taken]
    add_index :ifa_question_logs, [:organization_id, :act_subject_id, :is_calibrated, :date_taken]
    add_index :ifa_question_logs, [:classroom_id, :act_subject_id, :is_calibrated, :date_taken]
    add_index :ifa_question_logs, [:teacher_id, :act_subject_id, :is_calibrated, :date_taken]
    add_index :ifa_question_logs, [:act_assessment_id, :date_taken]
    add_index :ifa_question_logs, [:act_submission_id]
    remove_index :ifa_question_logs, [:act_submission_id,:act_question_id] 
    remove_index :ifa_question_logs, [:user_id, :act_subject_id, :period_end]    
    remove_index :ifa_question_logs, [:organiztion_id, :act_subject_id, :period_end]
    remove_index :ifa_question_logs, [:classroom_id, :act_subject_id, :period_end]    
    remove_index :ifa_question_logs, [:act_question_id, :act_submission_id]   
  end
end
