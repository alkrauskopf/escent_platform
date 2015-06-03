class RenameIsUserFiltrd < ActiveRecord::Migration
  def self.up

   rename_column :ifa_classroom_options, :is_user_filterd, :is_user_filtered
   
  end

  def self.down

   rename_column :ifa_classroom_options, :is_user_filtered, :is_user_filterd
  
  end
end
