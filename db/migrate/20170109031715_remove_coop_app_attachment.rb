class RemoveCoopAppAttachment < ActiveRecord::Migration
  def up
    remove_attachment :coop_apps, :picture
  end

  def down
    add_attachment :coop_apps, :picture
  end
end
