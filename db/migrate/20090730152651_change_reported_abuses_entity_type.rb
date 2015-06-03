class ChangeReportedAbusesEntityType < ActiveRecord::Migration
  def self.up
      change_column :reported_abuses , :entity_type , :string
  end

  def self.down
      raise ActiveRecord::IrreversibleMigration
  end
end
