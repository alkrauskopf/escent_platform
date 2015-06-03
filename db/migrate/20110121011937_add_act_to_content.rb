class AddActToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :act_score_range_id, :integer
    add_column :contents, :act_standard_id, :integer
    add_column :contents, :act_subject_id, :integer
    execute "UPDATE contents SET act_subject_id = 1"
  end

  def self.down
    remove_column :contents, :act_subject_id
    remove_column :contents, :act_standard_id
    remove_column :contents, :act_score_range_id
  end
end
