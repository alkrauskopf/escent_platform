class CreateSurveyAnons < ActiveRecord::Migration
  def self.up
    create_table :survey_anons do |t|
      t.integer :tlt_survey_type_id
      t.integer :tlt_survey_audience_id

      t.timestamps
    end
  add_index :survey_anons, :tlt_survey_type_id
  add_index :survey_anons, :tlt_survey_audience_id

  remove_column :tlt_survey_audiences, :is_anonymous
  remove_column :tlt_survey_types, :is_notify
  end

  def self.down
    drop_table :survey_anons

   add_column :tlt_survey_types, :is_notify, :boolean
   add_column :tlt_survey_audiences, :is_anonymous, :boolean
  end
end
