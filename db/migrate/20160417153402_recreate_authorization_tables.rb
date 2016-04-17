class RecreateAuthorizationTables < ActiveRecord::Migration
  def self.up
    drop_table :authorization_levels
    create_table "authorization_levels", :force => true do |t|
      t.string   "name",                         :null => false
      t.string   "description",  :limit => 1000
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "coop_app_id"
      t.text     "explanation"
    end

    add_index "authorization_levels", ["coop_app_id", "name"], :name => "app_name"

    drop_table :applicable_scopes
    create_table "applicable_scopes", :force => true do |t|
      t.integer  "authorization_level_id"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "applicable_scopes", ["authorization_level_id"], :name => "index_applicable_scopes_on_authorization_level_id"

  end

  def self.down

    drop_table :applicable_scopes
    create_table "applicable_scopes", :force => true do |t|
      t.integer  "authorization_level_id"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "old_level_id"
    end

    add_index "applicable_scopes", ["authorization_level_id"], :name => "index_applicable_scopes_on_authorization_level_id"
    add_index "applicable_scopes", ["old_level_id"], :name => "old_level"

    drop_table :authorization_levels
    create_table "authorization_levels", :force => true do |t|
      t.string   "name",                         :null => false
      t.string   "description",  :limit => 1000
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "coop_app_id"
      t.text     "explanation"
      t.integer  "old_level_id"
    end

    add_index "authorization_levels", ["coop_app_id", "name"], :name => "app_name"
    add_index "authorization_levels", ["name", "coop_app_id"], :name => "name_app"
  end
end
