class ChangeSkillToTextCoGle < ActiveRecord::Migration
  def self.up

    remove_column :co_gles, :skill
    add_column :co_gles, :skill, :text

  
  end

  def self.down

    remove_column :co_gles, :skill
    add_column :co_gles, :skill, :string
  
  end
end
