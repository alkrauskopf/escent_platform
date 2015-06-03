class AddTltSurvyTypeToCycle < ActiveRecord::Migration
  def self.up
    remove_column  :dle_cycles, :is_surveable
    add_column  :dle_cycles, :tlt_survey_type_id, :integer
  end

  def self.down

    add_column  :dle_cycles, :is_surveable, :boolean
    remove_column  :dle_cycles, :tlt_survey_type_id

  end
end
