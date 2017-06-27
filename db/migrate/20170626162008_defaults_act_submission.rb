class DefaultsActSubmission < ActiveRecord::Migration
  def up
    change_column :act_submissions, :is_final, :boolean, :default => false
    change_column :act_submissions, :upper_score_bound, :integer, :default => 0
    change_column :act_submissions, :lower_score_bound, :integer, :default => 0
    change_column :act_submissions, :duration, :integer, :default => 0
    change_column :act_submissions, :is_user_dashboarded, :boolean, :default => false
    change_column :act_submissions, :is_classroom_dashboarded, :boolean, :default => false
    change_column :act_submissions, :is_org_dashboarded, :boolean, :default => false
    change_column :act_submissions, :is_auto_finalized, :boolean, :default => false
    change_column :act_submissions, :tot_points, :decimal, :precision => 3, :scale => 2, :default => 0.0
    change_column :act_submissions, :tot_choices, :integer, :default => 0
  end

  def down
    change_column :act_submissions, :is_final, :boolean
    change_column :act_submissions, :upper_score_bound, :integer
    change_column :act_submissions, :lower_score_bound, :integer
    change_column :act_submissions, :duration, :integer
    change_column :act_submissions, :is_user_dashboarded, :boolean
    change_column :act_submissions, :is_classroom_dashboarded, :boolean
    change_column :act_submissions, :is_org_dashboarded, :boolean
    change_column :act_submissions, :is_auto_finalized, :boolean
    change_column :act_submissions, :tot_points, :decimal, :precision => 3, :scale => 2
    change_column :act_submissions, :tot_choices, :integer
  end
end
