class AddAttachmentResourceToContents < ActiveRecord::Migration
  def self.up
    change_table :contents do |t|
      t.has_attached_file :resource
    end
  end

  def self.down
    drop_attached_file :contents, :resource
  end
end
