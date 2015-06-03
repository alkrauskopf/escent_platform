class AddTemplateIdToTltSession < ActiveRecord::Migration
  def self.up

    add_column   :tlt_sessions,:itl_template_id, :integer
    add_column   :itl_templates,:is_default, :boolean, :default=>false

    add_index   :tlt_sessions, :itl_template_id
  end

  def self.down

    remove_column   :tlt_sessions,:itl_template_id
    remove_column   :itl_templates,:is_default

  end
end
