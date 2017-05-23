class AddDefaultIfaCellColorsB < ActiveRecord::Migration
  def up
    add_column :ifa_org_options, :empty_cell_color, :string, :limit => 7, :default => '#fffefc'
    add_column :ifa_org_options, :empty_cell_font, :string, :limit => 7, :default => '#858c8a'
  end

  def down
    remove_column :ifa_org_options, :empty_cell_color
    remove_column :ifa_org_options, :empty_cell_font
  end
end
