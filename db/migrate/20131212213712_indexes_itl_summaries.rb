class IndexesItlSummaries < ActiveRecord::Migration
  def self.up

   remove_index :itl_summaries, [:organization_type_id, :yr_mnth_of, :subject_area_id]
   remove_index :itl_summaries, [:organization_id, :yr_mnth_of, :subject_area_id]

   add_index :itl_summaries, [:organization_type_id, :subject_area_id, :yr_mnth_of], :name => "orgtype_subject_month"
   add_index :itl_summaries, [:organization_id, :subject_area_id, :yr_mnth_of], :name => "org_subject_month"

  end

  def self.down
    
   remove_index :itl_summaries, [:organization_type_id, :subject_area_id, :yr_mnth_of]
   remove_index :itl_summaries, [:organization_id, :subject_area_id, :yr_mnth_of]

   add_index :itl_summaries, [:organization_type_id, :yr_mnth_of, :subject_area_id], :name => "orgtype_yrmnthof_subject"
   add_index :itl_summaries, [:organization_id, :yr_mnth_of, :subject_area_id], :name => "org_yrmnthof_subject"

  end
end
