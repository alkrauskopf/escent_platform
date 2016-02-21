class CreateTltSurveyAudiences < ActiveRecord::Migration
  def self.up
    create_table :tlt_survey_audiences do |t|
      t.integer :coop_app_id
      t.integer :organization_id
      t.string :audience, :limit => 15

      t.timestamps
    end
    add_index :tlt_survey_audiences, :coop_app_id, :name => 'coop_app'
    add_index :tlt_survey_audiences, :organization_id, :name => 'organization'
 
  end

  def self.down
    drop_table :tlt_survey_audiences
  end
end
