class AddRatingLabelAppMethod < ActiveRecord::Migration
  def self.up

    add_column   :app_methods,:rating_label, :string
    add_column   :app_method_log_ratings,:bar_color, :string
  end

  def self.down
    remove_column   :app_methods,:rating_label
    remove_column   :app_method_log_ratings,:bar_color
  end
end
