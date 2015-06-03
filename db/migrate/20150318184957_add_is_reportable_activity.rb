class AddIsReportableActivity < ActiveRecord::Migration
  def self.up
   add_column  :elt_types, :is_reportable, :boolean, :default=> true
  end

  def self.down
   remove_column  :elt_types, :is_reportable
  end
end
