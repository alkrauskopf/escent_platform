class MoreIfaIndexes2 < ActiveRecord::Migration
  def self.up

    add_index :classroom_referrals, :classroom_id
    add_index :classroom_referrals, :topic_id
    add_index :classroom_contents, :classroom_id
    add_index :classroom_contents, :content_id 
    
    add_index :act_bench_act_questions, :act_bench_id
    add_index :act_bench_act_questions, :act_question_id
    add_index :act_benches, :act_subject_id
    add_index :act_benches, :act_standard_id  
    add_index :act_benches, :act_score_range_id
    add_index :act_benches, :act_master_id
    add_index :act_benches, :act_bench_type_id

    add_index :act_choices, :act_question_id
    add_index :act_choices, :is_correct
    
    # add_index :act_question_act_score_ranges, :act_score_range_id
    # add_index :act_question_act_score_ranges, :act_question_id

    # add_index :act_question_act_standards, :act_standard_id
    # add_index :act_question_act_standards, :act_question_id
    
    add_index :act_question_readings, :act_question_id, :uniq => true   
    # add_index :act_questions, :act_subject_id
    add_index :act_questions, :act_rel_reading_id
    # add_index :act_questions, :user_id
    add_index :act_questions, :organization_id
    add_index :act_questions, :is_calibrated   
    add_index :act_questions, :is_locked 
    add_index :act_questions, :act_standard_id    
    add_index :act_questions, :act_score_range_id
    add_index :act_questions, :content_id    
    add_index :act_questions, :is_active
  
  end

  def self.down


    remove_index :classroom_referrals, :classroom_id
    remove_index :classroom_referrals, :topic_id
    remove_index :classroom_contents, :classroom_id
    remove_index :classroom_contents, :content_id 
    
    remove_index :act_bench_act_questions, :act_bench_id
    remove_index :act_bench_act_questions, :act_question_id
    remove_index :act_benches, :act_subject_id
    remove_index :act_benches, :act_standard_id  
    remove_index :act_benches, :act_score_range_id
    remove_index :act_benches, :act_master_id
    remove_index :act_benches, :act_bench_type_id

    remove_index :act_choices, :act_question_id
    remove_index :act_choices, :is_correct
    
    remove_index :act_question_act_score_ranges, :act_score_range_id
    remove_index :act_question_act_score_ranges, :act_question_id    

    remove_index :act_question_act_standards, :act_standard_id
    remove_index :act_question_act_standards, :act_question_id
    
    remove_index :act_question_readings, :act_question_id, :uniq => true   
    remove_index :act_questions, :act_subject_id    
    remove_index :act_questions, :act_rel_reading_id
    remove_index :act_questions, :user_id    
    remove_index :act_questions, :organization_id
    remove_index :act_questions, :is_calibrated   
    remove_index :act_questions, :is_locked 
    remove_index :act_questions, :act_standard_id    
    remove_index :act_questions, :act_score_range_id
    remove_index :act_questions, :content_id    
    remove_index :act_questions, :is_active
  
  end
end
