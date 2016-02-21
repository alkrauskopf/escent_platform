class IndexesItlSummaries < ActiveRecord::Migration
  def self.up

   add_index :itl_summaries, [:organization_type_id, :subject_area_id, :yr_mnth_of], :name => "orgtype_subject_month"
   add_index :itl_summaries, [:organization_id, :subject_area_id, :yr_mnth_of], :name => "org_subject_month"

  end

  def self.down

   remove_index :itl_summaries, [:organization_id, :subject_area_id, :yr_mnth_of]

  end
end
