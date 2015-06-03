class AddColorBackgroundAppmethods < ActiveRecord::Migration
  def self.up

    add_column   :app_methods,:dashboard_color, :string

  end

  def self.down

    remove_column   :app_methods,:dashboard_color

  end
end
