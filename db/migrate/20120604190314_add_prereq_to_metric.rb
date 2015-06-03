class AddPrereqToMetric < ActiveRecord::Migration
  def self.up
    remove_column :dle_metrics, :prereq    
    add_column :dle_metrics, :prereq, :string, :limit => 75
  end

  def self.down
    remove_column :dle_metrics, :prereq    
    add_column :dle_metrics, :prereq, :string, :limit => 30

  end
end
