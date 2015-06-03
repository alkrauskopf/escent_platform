class RenameBlogabableCoopapp < ActiveRecord::Migration
  def self.up
   rename_column  :coop_apps, :blogable, :is_blogable
  end

  def self.down
   rename_column  :coop_apps, :is_blogable, :blogable
  end
end
