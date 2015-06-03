class AddOrgTltSession < ActiveRecord::Migration
  def self.up

   add_column :tlt_sessions, :organization_id, :integer
   add_index  :tlt_sessions, :organization_id
 
  end

  def self.down
   remove_column :tlt_sessions, :organization_id
  end
end
