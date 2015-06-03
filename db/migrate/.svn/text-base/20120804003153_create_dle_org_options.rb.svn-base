class CreateDleOrgOptions < ActiveRecord::Migration
  def self.up
    create_table :dle_org_options do |t|
      t.integer :organization_id
      t.boolean :is_coach_enabled

      t.timestamps
    end
  end

  def self.down
    drop_table :dle_org_options
  end
end
