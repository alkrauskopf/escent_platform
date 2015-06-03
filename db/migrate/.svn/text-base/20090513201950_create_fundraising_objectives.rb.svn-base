class CreateFundraisingObjectives < ActiveRecord::Migration
  def self.up
    create_table :fundraising_objectives do |t|
      t.string :name
      t.string :description, :limit => 8000
      t.integer :organization_id
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :merchant_account_id
      t.decimal :goal_total
      t.decimal :suggested_amount

      t.timestamps
    end
  end

  def self.down
    drop_table :fundraising_objectives
  end
end
