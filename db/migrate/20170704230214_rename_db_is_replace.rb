class RenameDbIsReplace < ActiveRecord::Migration
  def up
    remove_column :ifa_dashboards, :is_replaced
    add_column :ifa_dashboards, :needs_redash, :boolean, :default => false
  end

  def down
    add_column :ifa_dashboards, :is_replaced, :boolean, :default => false
    remove_column :ifa_dashboards, :needs_redash
  end
end
