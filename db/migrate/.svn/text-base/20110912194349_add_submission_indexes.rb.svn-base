class AddSubmissionIndexes < ActiveRecord::Migration
  def self.up
 
    add_index :topics, :classroom_id
    add_index :classrooms, :status
    add_index :subject_areas, :act_subject_id   
    add_index :users, :home_org_id 
    add_index :act_score_range_topics, :topic_id     
    add_index :act_score_range_topics, :act_score_range_id    
    add_index :homeworks, :classroom_id
    add_index :homeworks, :user_id
    add_index :homeworks, :teacher_id
    add_index :act_assessments, :act_subject_id
    add_index :act_assessments, :user_id
    add_index :act_assessments, :organization_id
    add_index :act_assessments, :is_active
    add_index :act_assessments, :is_calibrated
    add_index :act_assessment_act_questions, :act_assessment_id
    add_index :act_assessment_act_questions, :act_question_id
    add_index :act_assessment_classrooms, :act_assessment_id
    add_index :act_assessment_classrooms, :classroom_id
    add_index :act_assessment_score_ranges, :act_assessment_id
    add_index :act_assessment_score_ranges, :act_master_id
    add_index :act_assessment_score_ranges, :upper_score
    add_index :ifa_org_options, :organization_id, :unique => true
    add_index :ifa_classroom_options, :classroom_id, :unique => true
    add_index :ifa_user_options, :user_id, :unique => true
   
  end

  def self.down
 
    remove_index :topics, :classroom_id
    remove_index :classrooms, :status
    remove_index :subject_areas, :act_subject_id   
    remove_index :users, :home_org_id 
    remove_index :act_score_range_topics, :topic_id     
    remove_index :act_score_range_topics, :act_score_range_id    
    remove_index :homeworks, :classroom_id
    remove_index :homeworks, :user_id
    remove_index :homeworks, :teacher_id
    remove_index :act_assessments, :act_subject_id
    remove_index :act_assessments, :user_id
    remove_index :act_assessments, :organization_id
    remove_index :act_assessments, :is_active
    remove_index :act_assessments, :is_calibrated
    remove_index :act_assessment_act_questions, :act_assessment_id
    remove_index :act_assessment_act_questions, :act_question_id
    remove_index :act_assessment_classrooms, :act_assessment_id
    remove_index :act_assessment_classrooms, :classroom_id
    remove_index :act_assessment_score_ranges, :act_assessment_id
    remove_index :act_assessment_score_ranges, :act_master_id
    remove_index :act_assessment_score_ranges, :upper_score
    remove_index :ifa_org_options, :organization_id, :unique => true
    remove_index :ifa_classroom_options, :classroom_id, :unique => true
    remove_index :ifa_user_options, :user_id, :unique => true


  end
end
