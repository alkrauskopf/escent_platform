class AddAppIdSurveys < ActiveRecord::Migration
  def self.up
    add_column :tlt_survey_types, :coop_app_id, :integer
  end

  def self.down
    remove_column :tlt_survey_types, :coop_app_id
  end
end
