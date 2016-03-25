class ChangeBlogPositionDefault < ActiveRecord::Migration
  def self.up
    change_column_default :blogs, :position, 1
  end

  def self.down
    change_column_default :blogs, :position, null
  end
end
