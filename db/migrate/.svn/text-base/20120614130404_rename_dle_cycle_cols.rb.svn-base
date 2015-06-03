class RenameDleCycleCols < ActiveRecord::Migration
  def self.up

     remove_column  :user_dle_plans, :evaluation
     remove_column  :user_dle_plans, :input_notes
     rename_column  :dle_cycles, :is_observation, :is_output
     rename_column  :dle_cycles, :is_evaluation, :is_actual
     remove_column  :dle_cycles, :is_goals
     remove_column  :dle_cycles, :input_label
  end

  def self.down
     add_column  :user_dle_plans, :evaluation, :text
     add_column  :user_dle_plans, :input_notes, :text
     rename_column  :dle_cycles, :is_output, :is_observation
     rename_column  :dle_cycles, :is_actual, :is_evaluation
     add_column  :dle_cycles, :is_goals, :boolean
     add_column  :dle_cycles, :input_label, :string
  end
end
