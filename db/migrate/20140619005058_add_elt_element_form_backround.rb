class AddEltElementFormBackround < ActiveRecord::Migration
  def self.up

    remove_column  :elt_indicators, :form_background
    add_column  :elt_elements, :i_form_background, :string, :limit=>7
    add_column  :elt_elements, :e_font_color, :string, :limit=>7
  end

  def self.down
    remove_column  :elt_elements, :i_form_background
    remove_column  :elt_elements, :e_font_color
    add_column  :elt_indicators, :form_background, :string, :limit=>7

  end
end
