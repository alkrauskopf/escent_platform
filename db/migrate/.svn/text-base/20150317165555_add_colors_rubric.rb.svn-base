class AddColorsRubric < ActiveRecord::Migration
  def self.up
    add_column  :rubrics, :color_background, :string, :limit=>7
    add_column  :rubrics, :color_font, :string, :limit=>7
  end

  def self.down
    remove_column  :rubrics, :color_background
    remove_column  :rubrics, :color_font
  end
end
