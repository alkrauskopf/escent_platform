class IndexesForSurveys < ActiveRecord::Migration
  def self.up

    add_index :survey_schedules, [:entity_type, :entity_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "entity_audience_type"
    add_index :survey_schedules, [:entity_type, :entity_id, :organization_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "entity_org_audience_type"
    add_index :survey_schedules, [:organization_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "org_audience_type"
    add_index :survey_schedules, [:organization_id, :entity_type, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "org_entity_audience_type"
    add_index :survey_schedules, [:survey_instruction_id, :organization_id], :name => "instruction_org"
    add_index :survey_schedules, [:user_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "user_audience_type"
    add_index :survey_schedules, [:user_id, :organization_id, :entity_type], :name => "user_org_entity"
    remove_index :survey_schedules, :user_id
    remove_index :survey_schedules, :survey_instruction_id
    remove_index :survey_schedules, :tlt_survey_type_id
    remove_index :survey_schedules, :tlt_survey_audience_id
    remove_index :survey_schedules, :entity_id    
    remove_index :survey_schedules, :entity_type 
    remove_index :survey_schedules, :organization_id 

  end

  def self.down
    remove_index :survey_schedules, [:entity_type, :entity_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "entity_audience_type"
    remove_index :survey_schedules, [:entity_type, :entity_id, :organization_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "entity_org_audience_type"
    remove_index :survey_schedules, [:organization_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "org_audience_type"
    remove_index :survey_schedules, [:organization_id, :entity_type, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "org_entity_audience_type"
    remove_index :survey_schedules, [:survey_instruction_id, :organization_id], :name => "instruction_org"
    remove_index :survey_schedules, [:user_id, :tlt_survey_audience_id, :tlt_survey_type_id], :name => "user_audience_type"
    remove_index :survey_schedules, [:user_id, :organization_id, :entity_type], :name => "user_org_entity"
    add_index :survey_schedules, :user_id
    add_index :survey_schedules, :survey_instruction_id
    add_index :survey_schedules, :tlt_survey_type_id
    add_index :survey_schedules, :tlt_survey_audience_id
    add_index :survey_schedules, :entity_id    
    add_index :survey_schedules, :entity_type 
    add_index :survey_schedules, :organization_id 
  end
end
