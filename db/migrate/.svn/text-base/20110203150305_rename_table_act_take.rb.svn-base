class RenameTableActTake < ActiveRecord::Migration
  def self.up
    rename_table :act_taken_assessments, :act_submissions
  end

  def self.down
    rename_table  :act_submissions, :act_taken_assessments
  end
end
