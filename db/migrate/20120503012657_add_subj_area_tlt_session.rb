class AddSubjAreaTltSession < ActiveRecord::Migration
  def self.up

   add_column :tlt_sessions, :subject_area_id, :integer
   add_index  :tlt_sessions, :subject_area_id
 
  end

  def self.down
   remove_column :tlt_sessions, :subject_area_id
  end
end
