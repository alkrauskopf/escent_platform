class AddDurationToActSubmission < ActiveRecord::Migration
  def self.up

    add_column :act_submissions, :duration, :integer 
    execute "UPDATE act_submissions SET duration = 0"   
  
  end

  def self.down

    remove_column :act_submissions, :duration  
  
  end
end
