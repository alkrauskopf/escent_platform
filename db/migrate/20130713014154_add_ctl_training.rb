class AddCtlTraining < ActiveRecord::Migration
  def self.up

  add_column  :tlt_sessions, :is_training, :boolean
  add_column  :itl_org_options, :classroom_period_id, :integer

  execute "UPDATE tlt_sessions SET is_training = 0"
  end

  def self.down

  remove_column  :tlt_sessions, :is_training
  remove_column  :itl_org_options, :classroom_period_id

  end
end
