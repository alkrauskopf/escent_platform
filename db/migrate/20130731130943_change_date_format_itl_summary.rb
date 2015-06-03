class ChangeDateFormatItlSummary < ActiveRecord::Migration
  def self.up

   remove_index :itl_summaries, [:organization_id, :yr_mnth, :subject_area_id]
   remove_index :itl_summaries, [:organization_type_id, :yr_mnth, :subject_area_id]
   remove_index :itl_summaries, [:classroom_id, :yr_mnth]

   remove_column :itl_summaries, :yr_mnth

   add_column :itl_summaries, :yr_mnth_of, :date
   add_index :itl_summaries, [:organization_type_id, :yr_mnth_of, :subject_area_id], :name => "orgtype_yrmnthof_subject"
   add_index :itl_summaries, [:classroom_id, :yr_mnth_of], :name => "classroom_yrmnthof"
   add_index :itl_summaries, [:organization_id, :yr_mnth_of, :subject_area_id], :name => "org_yrmnthof_subject"



  end

  def self.down

   remove_column :itl_summaries, :yr_mnth_of

   add_column :itl_summaries, :yr_mnth, :integer
   add_index :itl_summaries, [:organization_type_id, :yr_mnth, :subject_area_id], :name => "orgtype_period_subject"
   add_index :itl_summaries, [:classroom_id, :yr_mnth], :name => "classroom_yrmnth"
   add_index :itl_summaries, [:organization_id, :yr_mnth, :subject_area_id], :name => "org_period_subject"

  end
end
