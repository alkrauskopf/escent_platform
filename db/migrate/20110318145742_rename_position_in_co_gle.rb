class RenamePositionInCoGle < ActiveRecord::Migration
  def self.up

    rename_column :co_gles, :position, :gle_position
  
  end

  def self.down

    rename_column :co_gles, :gle_position, :position
  
  end
end
