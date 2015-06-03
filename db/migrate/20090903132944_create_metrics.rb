class CreateMetrics < ActiveRecord::Migration
  def self.up
    create_table :metrics do |t|
      t.integer :user_id , :organization_id , :share_type
      t.timestamps
    end
  end

  def self.down
    drop_table :metrics
  end
end
