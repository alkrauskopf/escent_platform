class AddIsSurveyToCycle < ActiveRecord::Migration
  def self.up
    add_column :dle_cycles, :is_surveable, :boolean
    add_column :dle_cycles, :is_updateable, :boolean
    add_column :dle_cycles, :is_attachable, :boolean
  end

  def self.down
    remove_column :dle_cycles, :is_surveable
    remove_column :dle_cycles, :is_updateable
    remove_column :dle_cycles, :is_attachable
  end
end
