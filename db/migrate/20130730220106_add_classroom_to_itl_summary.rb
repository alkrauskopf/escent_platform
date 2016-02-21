class AddClassroomToItlSummary < ActiveRecord::Migration
  def self.up


    remove_column  :itl_summaries, :user_id
    add_column   :itl_summaries,:classroom_id, :integer


    
  end

  def self.down
    add_column  :itl_summaries, :user_id, :integer
    remove_column   :itl_summaries,:classroom_id

  end
end
