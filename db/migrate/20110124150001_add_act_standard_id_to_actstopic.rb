class AddActStandardIdToActstopic < ActiveRecord::Migration
  def self.up
    add_column :act_standard_topics, :act_standard_id,:integer
  end

  def self.down
    remove_column :act_standard_topics, :act_standard_id
  end
end
