class MoreIfaIndexes3 < ActiveRecord::Migration
  def self.up
    
    add_index :act_rel_reading_act_score_ranges, :act_score_range_id
    add_index :act_rel_reading_act_score_ranges, :act_rel_reading_id   

    add_index :act_rel_readings, :act_subject_id
    add_index :act_rel_readings, :act_genre_id  
    add_index :act_rel_readings, :user_id
    add_index :act_rel_readings, :organization_id

    add_index :act_score_range_contents, :act_score_range_id
    add_index :act_score_range_contents, :content_id

    add_index :act_score_ranges, :act_subject_id
    add_index :act_score_ranges, :upper_score   
    add_index :act_score_ranges, :act_master_id 

    add_index :act_standard_contents, :act_standard_id
    add_index :act_standard_contents, :content_id
    
    add_index :act_standard_topics, :act_standard_id
    add_index :act_standard_topics, :topic_id
    
    add_index :act_standards, :act_subject_id
    add_index :act_standards, :act_master_id

    add_index :act_submission_scores, :act_submission_id
    add_index :act_submission_scores, :act_master_id
    add_index :act_submissions, :is_final
    
    add_index :co_gles, :act_standard_id    
    add_index :co_gles, :co_grade_level_id
    
  end

  def self.down

    
    remove_index :act_rel_reading_act_score_ranges, :act_score_range_id
    remove_index :act_rel_reading_act_score_ranges, :act_rel_reading_id   

    remove_index :act_rel_readings, :act_subject_id
    remove_index :act_rel_readings, :act_genre_id  
    remove_index :act_rel_readings, :user_id
    remove_index :act_rel_readings, :organization_id

    remove_index :act_score_range_contents, :act_score_range_id
    remove_index :act_score_range_contents, :content_id

    remove_index :act_score_ranges, :act_subject_id
    remove_index :act_score_ranges, :upper_score   
    remove_index :act_score_ranges, :act_master_id 

    remove_index :act_standard_contents, :act_standard_id
    remove_index :act_standard_contents, :content_id
    
    remove_index :act_standard_topics, :act_standard_id
    remove_index :act_standard_topics, :topic_id
    
    remove_index :act_standards, :act_subject_id
    remove_index :act_standards, :act_master_id

    remove_index :act_submission_scores, :act_submission_id
    remove_index :act_submission_scores, :act_master_id
    remove_index :act_submissions, :is_final
    
    remove_index :co_gles, :act_standard_id    
    remove_index :co_gles, :co_grade_level_id
  
  end
end
