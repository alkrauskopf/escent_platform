class AddDescriptionToInstructions < ActiveRecord::Migration
  def self.up
   add_column  :survey_instructions, :description, :text
  end

  def self.down
   remove_column  :survey_instructions, :description
  end
end
