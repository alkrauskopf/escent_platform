class RenameCoStandardIdInCoGle < ActiveRecord::Migration
  def self.up

    rename_column :co_gles, :co_standard_id, :act_standard_id  
  
  end

  def self.down

    rename_column :co_gles, :act_standard_id  , :co_standard_id
  
  end
end
