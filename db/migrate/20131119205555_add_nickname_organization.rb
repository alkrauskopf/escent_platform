class AddNicknameOrganization < ActiveRecord::Migration
  def self.up

    add_column   :organizations,:nick_name, :string, :default=>""

  end

  def self.down

    remove_column   :organizations,:nick_name

  end
end
