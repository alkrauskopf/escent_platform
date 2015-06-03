class AddLabelsToCycle < ActiveRecord::Migration
  def self.up
    add_column :dle_cycles, :input_label, :string
    add_column :dle_cycles, :output_label, :string
    rename_column :user_dle_plans, :observations, :input_notes
    rename_column :user_dle_plans, :goals, :output_notes
  end

  def self.down
    remove_column :dle_cycles, :input_label
    remove_column :dle_cycles, :output_label
    rename_column :user_dle_plans, :input_notes, :observations
    rename_column :user_dle_plans, :output_notes, :goals
  end
end
