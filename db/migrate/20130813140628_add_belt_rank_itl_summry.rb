class AddBeltRankItlSummry < ActiveRecord::Migration
  def self.up

    add_column   :itl_summaries,:itl_belt_rank_id, :integer

    add_index :itl_summaries, [:itl_belt_rank_id, :organization_id, :subject_area_id, :yr_mnth_of], :name => "belt_org_subj_yrmnth"
  
    execute "UPDATE itl_summaries SET itl_belt_rank_id = 99"

  end

  def self.down
    remove_column   :itl_summaries,:itl_belt_rank_id
  end
end
