class RemoveOrIdFromAudience < ActiveRecord::Migration
  def self.up
    remove_column :tlt_survey_audiences, :organization_id
  end

  def self.down
    add_column :tlt_survey_audiences, :organization_id, :integer
  end
end
