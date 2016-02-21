class ChangeDateFormatItlSummary < ActiveRecord::Migration
  def self.up




   remove_column :itl_summaries, :yr_mnth

   add_column :itl_summaries, :yr_mnth_of, :date
   add_index :itl_summaries, [:classroom_id, :yr_mnth_of], :name => "classroom_yrmnthof"
  end

  def self.down

   remove_column :itl_summaries, :yr_mnth_of

   add_column :itl_summaries, :yr_mnth, :integer

  end
end
