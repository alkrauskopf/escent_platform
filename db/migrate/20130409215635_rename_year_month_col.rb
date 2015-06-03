class RenameYearMonthCol < ActiveRecord::Migration
  def self.up
    remove_index :itl_summaries, [:user_id, :year_month, :subject_area_id, :organization_id]
    remove_index :itl_summaries, [:organization_type_id, :year_month, :subject_area_id]

    rename_column  :itl_summaries, :year_month, :yr_mnth

    add_index :itl_summaries, [:user_id, :yr_mnth, :subject_area_id, :organization_id], :name => "user_period_subject_org"
    add_index :itl_summaries, [:organization_type_id, :yr_mnth, :subject_area_id], :name => "orgtype_period_subject"

  end

  def self.down
    remove_index :itl_summaries, [:user_id, :yr_mnth, :subject_area_id, :organization_id]
    remove_index :itl_summaries, [:organization_type_id, :yr_mnth, :subject_area_id]

    rename_column  :itl_summaries, :yr_mnth, :year_month

    add_index :itl_summaries, [:user_id, :year_month, :subject_area_id, :organization_id], :name => "user_period_subject_org"
    add_index :itl_summaries, [:organization_type_id, :year_month, :subject_area_id], :name => "orgtype_period_subject"

  end
end
