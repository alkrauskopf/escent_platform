class CreateTltSurveyAudiences < ActiveRecord::Migration
  def self.up
    create_table :tlt_survey_audiences do |t|
      t.integer :coop_app_id
      t.integer :organization_id
      t.string :audience, :limit => 15

      t.timestamps
    end
    add_index :tlt_survey_audiences, :coop_app_id
    add_index :tlt_survey_audiences, :organization_id    
 
  end

  def self.down
    drop_table :tlt_survey_audiences
  end
end
