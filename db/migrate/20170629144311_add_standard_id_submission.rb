class AddStandardIdSubmission < ActiveRecord::Migration
  def up
    add_column :act_submissions, :act_master_id, :integer
    add_index :act_submissions, [:act_master_id]
  end

  def down
    remove_column :act_submissions, :act_master_id
  end
end
