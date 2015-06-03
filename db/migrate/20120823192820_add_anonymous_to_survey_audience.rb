class AddAnonymousToSurveyAudience < ActiveRecord::Migration
  def self.up

  add_column :tlt_survey_audiences, :is_anonymous, :boolean

  end

  def self.down

  remove_column :tlt_survey_audiences, :is_anonymous

  end
end
