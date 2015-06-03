class AddSeqNumTlActivityType < ActiveRecord::Migration
  def self.up
   add_column :tl_activity_types, :seq_num, :integer
   add_index  :tl_activity_types, :seq_num

  end

  def self.down

   remove_column :tl_activity_types, :seq_num

  end
end
