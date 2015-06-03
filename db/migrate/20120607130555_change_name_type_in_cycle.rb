class ChangeNameTypeInCycle < ActiveRecord::Migration
  def self.up
    remove_column :tlt_survey_types, :name
  end

  def self.down
    add_column :tlt_survey_types, :name, :string
  end
end
