class AddPurposeToCycle < ActiveRecord::Migration
  def self.up

   add_column :dle_cycles, :purpose, :text
   add_column :dle_metrics, :position, :integer
   add_column :dle_metrics, :prereq, :string, :limit => 30
  end

  def self.down
   remove_column :dle_cycles, :purpose
   remove_column :dle_metrics, :position
   remove_column :dle_metrics, :prereq

  end
end
