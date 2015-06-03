class CreateTltDiagnostics < ActiveRecord::Migration
  def self.up
    create_table :tlt_diagnostics do |t|
      t.integer :user_id
      t.text :conclusions

      t.timestamps
    end
  end

  def self.down
    drop_table :tlt_diagnostics
  end
end
