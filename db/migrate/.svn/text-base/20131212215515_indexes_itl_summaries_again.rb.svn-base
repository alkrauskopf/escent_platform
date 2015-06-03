class IndexesItlSummariesAgain < ActiveRecord::Migration
  def self.up

   add_index :itl_summaries, [:organization_type_id, :yr_mnth_of], :name => "orgtype_month"
   add_index :itl_summaries, [:organization_id, :yr_mnth_of], :name => "org_month"

  end

  def self.down

   remove_index :itl_summaries, [:organization_type_id, :yr_mnth_of]
   remove_index :itl_summaries, [:organization_id, :yr_mnth_of]

  end
end
