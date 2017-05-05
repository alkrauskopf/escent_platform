class AddColorsIdaStrands < ActiveRecord::Migration
  def up
    add_column  :act_standards, :strand_background, :string, :limit=>7, :default=>'#F8F8F8'
    add_column  :act_standards, :strand_font, :string, :limit=>7, :default=>'#000000'
  end

  def down
    remove_column  :act_standards, :strand_background
    remove_column  :act_standards, :strand_font
  end
end
