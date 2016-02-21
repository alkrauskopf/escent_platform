class AddActStandardContentsIndexes < ActiveRecord::Migration
  def self.up
    remove_index :act_standard_contents, [:act_standard_id]
    remove_index :act_standard_contents, [:content_id]
    add_index :act_standard_contents, [:act_standard_id, :content_id]
    add_index :act_standard_contents, [:content_id, :act_standard_id]
  end

  def self.down
  end
end
