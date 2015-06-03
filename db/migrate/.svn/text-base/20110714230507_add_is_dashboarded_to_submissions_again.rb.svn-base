class AddIsDashboardedToSubmissionsAgain < ActiveRecord::Migration
  def self.up

   add_column :act_submissions, :is_user_dashboarded, :boolean 
   add_column :act_submissions, :is_classroom_dashboarded, :boolean 
   add_column :act_submissions, :is_org_dashboarded, :boolean 
   
  end

  def self.down
   remove_column :act_submissions, :is_user_dashboarded, :boolean 
   remove_column :act_submissions, :is_classroom_dashboarded, :boolean 
   remove_column :act_submissions, :is_org_dashboarded, :boolean 
  
  end
end
