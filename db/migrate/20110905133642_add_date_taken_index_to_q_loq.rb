class AddDateTakenIndexToQLoq < ActiveRecord::Migration
  def self.up

    # add_index :ifa_question_logs, [:user_id, :act_subject_id, :date_taken]
    # add_index :ifa_question_logs, [:organiztion_id, :act_subject_id, :date_taken]
    # add_index :ifa_question_logs, [:classroom_id, :act_subject_id, :date_taken]

  end

  def self.down
 

    # remove_index :ifa_question_logs, [:user_id, :act_subject_id, :date_taken]
    # remove_index :ifa_question_logs, [:organiztion_id, :act_subject_id, :date_taken]
    # remove_index :ifa_question_logs, [:classroom_id, :act_subject_id, :date_taken]
  end
  
  end
