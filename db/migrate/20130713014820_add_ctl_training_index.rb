class AddCtlTrainingIndex < ActiveRecord::Migration
  def self.up

    add_index :itl_org_options, :classroom_period_id

  end

  def self.down

    remove_index :itl_org_options, :classroom_period_id

  end
end
