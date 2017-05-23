class AddDefaultIfaCellColors < ActiveRecord::Migration
  def up
    add_column :ifa_org_options, :remedial_color, :string, :limit => 7, :default => '#ff7668'
    add_column :ifa_org_options, :remedial_font, :string, :limit => 7, :default => '#333333'
    add_column :ifa_org_options, :growth_color, :string, :limit => 7, :default => '#ffe768'
    add_column :ifa_org_options, :growth_font, :string, :limit => 7, :default => '#333333'
    add_column :ifa_org_options, :mastery_color, :string, :limit => 7, :default => '#bddc59'
    add_column :ifa_org_options, :mastery_font, :string, :limit => 7, :default => '#333333'
  end

  def down
    remove_column :ifa_org_options, :remedial_color
    remove_column :ifa_org_options, :remedial_font
    remove_column :ifa_org_options, :growth_color
    remove_column :ifa_org_options, :growth_font
    remove_column :ifa_org_options, :mastery_color
    remove_column :ifa_org_options, :mastery_font
  end
end
