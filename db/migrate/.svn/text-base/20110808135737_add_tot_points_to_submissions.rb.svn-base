class AddTotPointsToSubmissions < ActiveRecord::Migration
  def self.up

    add_column :act_submissions, :tot_points, :decimal, :precision=>3, :scale => 2  
    add_column :act_submissions, :tot_choices,:integer
    remove_column :act_submissions, :est_sms
    remove_column :act_submissions, :final_sms
  end

  def self.down
    remove_column :act_submissions, :tot_choices
    remove_column :act_submissions, :tot_points
    add_column :act_submissions, :est_sms, :integer
    add_column :act_submissions, :final_sms, :integer 
  
  end
end
