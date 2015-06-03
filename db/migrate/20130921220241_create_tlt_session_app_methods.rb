class CreateTltSessionAppMethods < ActiveRecord::Migration
  def self.up
    create_table :tlt_session_app_methods do |t|
      t.integer :tlt_session_id
      t.integer :app_method_id

      t.timestamps
    end
    add_index :tlt_session_app_methods, :tlt_session_id
    add_index :tlt_session_app_methods, [:app_method_id, :tlt_session_id], :name => "app_method_session"

  end

  def self.down
    drop_table :tlt_session_app_methods
  end
end
