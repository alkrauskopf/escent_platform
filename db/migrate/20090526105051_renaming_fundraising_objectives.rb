class RenamingFundraisingObjectives < ActiveRecord::Migration
  def self.up
    rename_table :fundraising_objectives, :fundraising_campaigns
    rename_column :fundraising_campaigns, :goal_total, :goal_amount
    change_column :fundraising_campaigns, :goal_amount, :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :fundraising_campaigns, :suggested_amount, :decimal, :precision => 12, :scale => 2, :default => 0.0
    rename_column :payments, :fundraising_objective_id, :fundraising_campaign_id
  end

  def self.down
    rename_column :fundraising_campaigns, :goal_amount, :goal_total
    rename_table :fundraising_campaigns, :fundraising_objectives
    rename_column :payments, :fundraising_campaign_id, :fundraising_objective_id
  end
end
