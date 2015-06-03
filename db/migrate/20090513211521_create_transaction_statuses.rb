class CreateTransactionStatuses < ActiveRecord::Migration
  def self.up
    create_table :transaction_statuses do |t|
      t.string :name, :limit => 32
      t.string :color, :limit => 8
      t.string :description, :limit => 1024

      t.timestamps
    end
  end

  def self.down
    drop_table :transaction_statuses
  end
end
