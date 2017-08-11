class AddIfaPlannable < ActiveRecord::Migration
  def up
    add_column :ifa_org_options, :is_plannable, :boolean, :default=>true
  end

  def down
    remove_column :ifa_org_options, :is_plannable
  end
end
