class AddIsAutoFinalizedToActSubmissions < ActiveRecord::Migration
  def self.up

   add_column :act_submissions, :is_auto_finalized, :boolean

  end

  def self.down

   remove_column :act_submissions, :is_auto_finalized
  
  end
end
