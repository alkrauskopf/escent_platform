class AddBlogabableCoopapp < ActiveRecord::Migration
  def self.up
   add_column  :coop_apps, :blogable, :boolean, :default=> false
  end

  def self.down
   remove_column  :coop_apps, :blogable
  end
end
