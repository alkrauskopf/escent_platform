class AddClassroomToItlSummary < ActiveRecord::Migration
  def self.up

    remove_index :itl_summaries, [:user_id, :yr_mnth, :subject_area_id, :organization_id]

    remove_column  :itl_summaries, :user_id
    add_column   :itl_summaries,:classroom_id, :integer

    add_index :itl_summaries, [:classroom_id, :yr_mnth], :name => "classroom_yrmnth"
      
    
  end

  def self.down
    add_column  :itl_summaries, :user_id, :integer
    remove_column   :itl_summaries,:classroom_id

   add_index :itl_summaries, [:user_id, :yr_mnth, :subject_area_id, :organization_id], :name => "user_period_subject_org"

  end
end
