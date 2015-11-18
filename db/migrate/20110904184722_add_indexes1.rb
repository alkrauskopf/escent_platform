class AddIndexes1 < ActiveRecord::Migration
  def self.up
 
    add_index :classrooms, :user_id
    add_index :classrooms, :organization_id
    add_index :classrooms, :act_subject_id 
    add_index :classrooms, :subject_area_id
    add_index :contents, :user_id
    add_index :contents, :organization_id
    add_index :contents, :act_subject_id 
    add_index :contents, :subject_area_id
    add_index :contents, :content_resource_type_id
    add_index :topics, :act_score_range_id    
    # add_index :topic_contents, :topic_id
    add_index :topic_contents, :content_id
    add_index :act_question_act_score_ranges, :act_score_range_id
    add_index :act_question_act_score_ranges, :act_question_id
    add_index :act_question_act_standards, :act_standard_id
    add_index :act_question_act_standards, :act_question_id
    add_index :act_questions, :act_subject_id
    add_index :act_questions, :user_id

  
  end

  def self.down

    remove_index :classrooms, :user_id
    remove_index :classrooms, :organization_id
    remove_index :classrooms, :act_subject_id 
    remove_index :classrooms, :subject_area_id
    remove_index :contents, :user_id
    remove_index :contents, :organization_id
    remove_index :contents, :act_subject_id 
    remove_index :contents, :subject_area_id
    remove_index :contents, :content_resource_type_id
    remove_index :topics, :act_score_range_id    
    remove_index :topic_contents, :topic_id
    remove_index :topic_contents, :content_id
    remove_index :act_question_act_score_ranges, :act_score_range_id
    remove_index :act_question_act_score_ranges, :act_question_id
    remove_index :act_question_act_standards, :act_standard_id
    remove_index :act_question_act_standards, :act_question_id
    remove_index :act_questions, :act_subject_id
    remove_index :act_questions, :user_id
    
  end
end
