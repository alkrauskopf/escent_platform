class AddIsReviewedToTltSession < ActiveRecord::Migration
  def self.up
   add_column :tlt_sessions, :is_pending_review, :boolean
   add_column :tlt_sessions, :is_final, :boolean
   
   execute "UPDATE tlt_sessions SET is_pending_review = 0"
   execute "UPDATE tlt_sessions SET is_final = 0"
  end

  def self.down

   remove_column :tlt_sessions, :is_pending_review, :boolean
   remove_column :tlt_sessions, :is_final, :boolean

  end
end
