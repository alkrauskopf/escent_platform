class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table "address_types", :force => true do |t|
      t.datetime "created_at", "updated_at"
      t.string   "name",          :limit => 50,                     :null => false
    end
  
    create_table "addresses", :force => true do |t|
      t.integer  "address_type_id",                                 :null => false
      t.datetime "created_at", "updated_at"
      t.integer  "organization_id"
      t.integer  "user_id"
      t.string   "street1",        :limit => 150,                   :null => false
      t.string   "street2",        :limit => 150
      t.string   "city",           :limit => 150,                   :null => false
      t.string   "state",          :limit => 32,                    :null => false
      t.string   "country",        :limit => 3,   :default => "US", :null => false
      t.string   "postal_code",    :limit => 20,                    :null => false
    end
    
    create_table "channel_contents", :force => true do |t|
      t.integer  "channel_id",     :null => false
      t.integer  "content_id",     :null => false
      t.integer  "position"
      t.datetime "created_at", "updated_at"
    end
  
    create_table "channel_types", :force => true do |t|
      t.string   "name",          :limit => 50,                           :null => false
      t.string   "description",   :limit => 500
      t.datetime "created_at",                                            :null => false
      t.datetime "updated_at",                                            :null => false
    end
  
    create_table "channels",  :force => true do |t|
      t.integer  "parent_id"
      t.integer  "organization_id",                                       :null => false
      t.integer  "user_id",                                               :null => false
      t.string   "title",            :limit => 150,                       :null => false
      t.string   "description",      :limit => 500
      t.boolean  "enable_approval",                  :default => false,   :null => false
      t.datetime "created_at",                                            :null => false
      t.datetime "updated_at",                                            :null => false
      t.boolean  "is_searchable",                    :default => true,    :null => false
      t.datetime "publish_start_date",                                    :null => false
      t.datetime "publish_end_date"
      t.integer  "channel_type_id",                                       :null => false
    end
  
    create_table "contents",  :force => true do |t|
      t.integer  "child_content_id"
      t.integer  "related_content_type_id"
      t.integer  "content_status_id",                                           :null => false
      t.string   "title",                   :limit => 150,                      :null => false
      t.string   "description",             :limit => 4000
      t.integer  "organization_id",                                             :null => false
      t.integer  "user_id",                                                     :null => false
      t.datetime "created_at",                                                  :null => false
      t.datetime "updated_at",                                                  :null => false
      t.boolean  "is_mature_content",                       :default => false,  :null => false
      t.boolean  "is_enabled_user_rating",                  :default => false,  :null => false
      t.datetime "publish_start_date",                                          :null => false
      t.datetime "publish_end_date"
      t.string   "source_url",              :limit => 500
      t.string   "file_name",               :limit => 256
      t.string   "path_and_file_name",      :limit => 500
      t.string   "content_object_type",     :limit => 5
      t.binary   "content_object"
      t.integer  "package_id"
      t.string   "source_url_protocol",     :limit => 30
      t.boolean  "is_post",                                 :default => false,   :null => false
    end
  
    add_index "contents", ["content_object_type"]
  
    create_table "content_details", :force => true do |t|
      t.string   "content_details_key", :limit => 25,  :null => false
      t.integer  "content_id",                        :null => false
      t.string   "details_value",      :limit => 500
      t.datetime "created_at",                      :null => false
    end
  
#    create_table "content_html_error_log", :force => true do |t|
#      t.integer "content_id"
#      t.integer "err_Num"
#      t.string  "err_msg",    :limit => 4000
#    end
  
    create_table "content_log",  :force => true do |t|
      t.integer  "content_id",                      :null => false
      t.datetime "created_at",                     :null => false
      t.integer  "user_id",                         :null => false
      t.integer  "channel_id",                      :null => false
      t.string   "http_header",     :limit => 4000, :null => false
      t.integer  "organization_id"
      t.integer  "package_id"
    end
  
    create_table "content_object_type_groups", :force => true do |t|
      t.string   "name",                     :limit => 50, :null => false
      t.datetime "created_at",                            :null => false
    end
  
    create_table "content_object_type_players", :force => true do |t|
      t.string   "content_object_type", :limit => 5,                     :null => false
      t.string   "protocol",          :limit => 5, :default => "HTTP", :null => false
      t.integer  "organization_id",                                     :null => false
      t.integer  "player_id",                                           :null => false
      t.datetime "created_at",                                          :null => false
    end
  
    create_table "content_object_types", :force => true do |t|
      t.string   "content_object_type",        :limit => 5,                      :null => false
      t.integer  "content_object_type_group_id",                                   :null => false
      t.string   "name",                     :limit => 50,                     :null => false
      t.string   "mime_type",                 :limit => 100,                    :null => false
      t.boolean  "is_nested_content",                         :default => false, :null => false
    end
  
    create_table "content_rating_options",  :force => true do |t|
      t.integer  "content_rating_type_id",                  :null => false
      t.string   "name",                  :limit => 50,  :null => false
      t.string   "description",           :limit => 256
      t.datetime "created_at",                          :null => false
    end
  
    create_table "content_rating_types", :force => true do |t|
      t.string   "name",                :limit => 50,  :null => false
      t.string   "description",         :limit => 150, :null => false
      t.datetime "created_at",                        :null => false
    end
  
    create_table "content_ratings", :force => true do |t|
      t.integer  "content_rating_option_id", :null => false
      t.datetime "created_at",           :null => false
    end
  
    create_table "content_sources",  :force => true do |t|
      t.integer  "source_type_id",                :null => false
      t.string   "source_value",  :limit => 500, :null => false
      t.datetime "created_at",                 :null => false
    end
  
    create_table "content_source_types",  :force => true do |t|
      t.string   "name",         :limit => 50, :null => false
      t.datetime "created_at",                :null => false
    end
  
    create_table "content_statuses",  :force => true do |t|
      t.string   "name",            :limit => 50,  :null => false
      t.string   "description",     :limit => 500, :null => false
      t.datetime "created_at",                    :null => false
    end
  
    create_table "content_tags",  :force => true do |t|
      t.integer  "tag_id",       :null => false
      t.datetime "created_at", :null => false
    end
  
    create_table "content_trackings", :force => true do |t|
      t.integer  "tracking_type_id", :null => false
      t.integer  "content_id",      :null => false
      t.integer  "user_id",         :null => false
      t.datetime "created_at",    :null => false
    end
  
    create_table "content_tracking_types",  :force => true do |t|
      t.string   "name",           :limit => 50, :null => false
      t.datetime "created_at",                  :null => false
    end
  
    create_table "content_uploads", :force => true do |t|
      t.integer  "content_id",        :null => false
      t.string   "title",             :limit => 150,  :null => false
      t.string   "description",       :limit => 4000
      t.datetime "publish_start_date",                  :null => false
      t.datetime "publish_end_date"
      t.string   "source_url",         :limit => 500
      t.string   "file_name",          :limit => 256
      t.string   "path_and_file_name",   :limit => 500
      t.string   "content_object_type", :limit => 5
      t.binary   "content_object"
      t.string   "source_url_protocol", :limit => 30
    end
  
    create_table "countries",  :force => true do |t|
      t.string   "code",     :limit => 3,  :null => false
      t.datetime "created_at",               :null => false
      t.string   "name",        :limit => 50, :null => false
    end
  
    create_table "default_package_roles",  :force => true do |t|
      t.integer  "package_id",   :null => false
      t.integer  "role_id",   :null => false
      t.datetime "created_at", :null => false
    end
  
    create_table "denominations",  :force => true do |t|                                           
      t.string   "name",                 :limit => 150,                      :null => false
      t.datetime "created_at",                                              :null => false
      t.integer  "parent_id"
      t.integer  "channel_id"                                                
    end
  
    create_table "dwls", :force => true do |t|
      t.string "name", :limit => 50
    end
  
    create_table "event_logs",  :force => true do |t|
      t.integer  "event_log_type_id"
      t.integer  "user_id"
      t.integer  "channel_id"
      t.integer  "content_id"
      t.datetime "created_at",                   :null => false
      t.string   "event_data",      :limit => 500
    end
  
    create_table "event_log_types",  :force => true do |t|
      t.string   "name",           :limit => 50, :null => false
#      t.datetime "created_at",                  :null => false
    end
  
    create_table "roles",  :force => true do |t|
      t.string   "role_name",       :limit => 50,   :null => false
      t.datetime "created_at",                    :null => false
      t.integer  "organization_id"
      t.integer  "package_id"
      t.integer  "module_id"
      t.integer  "user_id",                         :null => false
      t.string   "description",    :limit => 1000
    end
  
    add_index "roles", ["organization_id", "role_name"], :name => "IDX_roles1"
    add_index "roles", ["role_name", "organization_id", "package_id", "module_id"], :name => "UK_FSNRoles2", :unique => true
  
    create_table "roles_granted_roles",  :force => true do |t|
      t.integer  "role_id",        :null => false
      t.integer  "granted_Role_id", :null => false
      t.datetime "created_at",      :null => false
    end
  
    add_index "roles_granted_roles", ["granted_role_id", "role_id"], :name => "IDX_FSNRolesGrantedRoles1", :unique => true
  
    create_table "user_roles",  :force => true do |t|
      t.integer  "user_id",                            :null => false
      t.integer  "role_id",                         :null => false
      t.datetime "created_at",                       :null => false
      t.boolean  "has_grant_option", :default => false, :null => false
      t.datetime "start_date"
      t.datetime "end_date"
    end
  
    create_table "organization_outreach_priorities",  :force => true do |t|
      t.integer  "organization_id",     :null => false
      t.integer  "outreach_priority_id", :null => false
      t.datetime "created_at",        :null => false
    end
  
    create_table "organization_sizes",  :force => true do |t|
      t.datetime "created_at",                      :null => false
      t.string   "description",        :limit => 50, :null => false
      t.integer  "value_low"
      t.integer  "value_high"
    end
  
    create_table "organization_types",  :force => true do |t|
      t.integer  "parent_id"
      t.datetime "created_at",                            :null => false
      t.string   "name",                     :limit => 50, :null => false
      t.string   "template_name"
    end
  
    create_table "associated_organizations",  :force => true do |t|
      t.integer  "organization_id", :null => false
      t.integer  "user_id",         :null => false
      t.datetime "created_at",      :null => false
    end
  
    create_table "organization_visits",  :force => true do |t|
      t.integer  "organization_id",                :null => false
      t.integer  "user_id"
      t.datetime "date_visited",                   :null => false
      t.integer  "visit_year",      :default => 0, :null => false
      t.integer  "visit_month",     :default => 0, :null => false
      t.integer  "visit_day",       :default => 0, :null => false
      t.integer  "visit_hour",      :default => 0, :null => false
      t.integer  "visit_minutes",   :default => 0, :null => false
    end
  
    add_index "organization_visits", ["organization_id", "visit_year", "visit_month", "visit_day"], :name => "IDX1_OrganizationVisits"
    add_index "organization_visits", ["visit_year", "visit_month", "visit_day"], :name => "IDX2_OrganizationVisits"
    add_index "organization_visits", ["organization_id", "date_visited"], :name => "IDX3_OrganizationVisits"
    add_index "organization_visits", ["date_visited"], :name => "IDX4_OrganizationVisits"
  
    create_table "organizations",  :force => true do |t|
      t.integer  "parent_id"
      t.integer  "organization_type_id",                                      :null => false
      t.string   "name",                  :limit => 200,                      :null => false
      t.datetime "created_at",                                                :null => false
      t.datetime "updated_at",                                                :null => false
      t.integer  "channel_id"
      t.integer  "denomination_id"
      t.string   "web_site_url",          :limit => 250
      t.integer  "iwing_tab_id"
      t.integer  "status_id",                                                 :null => false
      t.string   "phone",             :limit => 20
      t.string   "fax",               :limit => 20
      t.integer  "organization_size_id"
      t.integer  "package_id"
      t.string   "email_address",         :limit => 256
    end
  
    add_index "organizations", ["denomination_id"], :name => "IDX1_Organizations"
    add_index "organizations", ["organization_type_id"], :name => "IDX2_Organizations"
    
    create_table "outreach_priorities",  :force => true do |t|
      t.integer  "parent_id"
      t.string   "name",                     :limit => 50,                      :null => false
      t.datetime "created_at",                                                 :null => false
    end
  
    create_table "package_subscription_terms",  :force => true do |t|
      t.datetime "created_at",                             :null => false
      t.string   "time_period",                :limit => 50, :null => false
      t.integer  "days"
    end
  
    #Bruce needs to check this, old DNN?
    create_table "package_tabs",  :force => true do |t|
      t.integer  "tab_id",       :null => false
      t.datetime "created_at", :null => false
      t.integer  "tab_sequence", :null => false
    end
  
    create_table "package_types",  :force => true do |t|
      t.datetime "created_at",                  :null => false
      t.string   "name",          :limit => 150, :null => false
    end
  
    #Bruce - old dnn 
    create_table "packages",  :force => true do |t|
      t.integer  "base_package_id"
      t.datetime "created_at",                                                              :null => false
      t.integer  "organization_id",                                                           :null => false
      t.string   "name",                      :limit => 150,                                 :null => false
      t.string   "description",               :limit => 4000
      t.integer  "package_subscription_term_id"
      t.datetime "subscription_start_date"
      t.datetime "subscription_end_date"
      t.decimal  "price",                                     :precision => 18, :scale => 2
      t.string   "dnn_template_name"
      t.integer  "package_type_id",                                                            :null => false
      t.boolean  "is_public",                                                                 :null => false
      t.boolean  "is_deployable",                                                             :null => false
    end
  
    add_index "packages", ["organization_id", "name"], :name => "UK_Packages_OrgAndName", :unique => true
  
    create_table "permission_types",  :force => true do |t|
      t.string   "name",             :limit => 50, :null => false
      t.datetime "created_at",                    :null => false
    end
  
    create_table "permissions",  :force => true do |t|
      t.integer  "channel_id"
      t.integer  "content_id"
      t.integer  "user_id"
      t.integer  "role_id"
      t.integer  "permission_type_id", :null => false
      t.datetime "created_at",      :null => false
    end
    
    #Bruce - Why are we using composite key using permission id
    add_index "permissions", ["channel_id", "id"], :name => "IDX_Permissions1"
    add_index "permissions", ["content_id", "id"], :name => "IDX_Permissions2"
    add_index "permissions", ["user_id", "id"], :name => "IDX_Permissions3"
    add_index "permissions", ["role_id", "id"], :name => "IDX_Permissions4"
  
    create_table "players",  :force => true do |t|
      t.datetime "created_at",                 :null => false
      t.string   "name",        :limit => 50,   :null => false
      t.string   "version",     :limit => 20
      t.string   "protocol",    :limit => 30
      t.string   "description", :limit => 4000
      t.string   "html_code",    :limit => 4000
    end
  
    create_table "related_contents",  :force => true do |t|
      t.integer  "content_id",        :null => false
      t.datetime "created_at",      :null => false
    end
  
    create_table "related_content_types",  :force => true do |t|
      t.string   "name",                 :limit => 100, :null => false
      t.datetime "created_at",                         :null => false
    end
  
    create_table "related_organizations", :id => false, :force => true do |t|
      t.integer  "organization_id",        :null => false
      t.integer  "related_organization_id", :null => false
      t.datetime "created_at",           :null => false
    end
  
    create_table "states",  :force => true do |t|
      t.string   "state",        :limit => 32,                     :null => false
      t.string   "country",      :limit => 3,                     :null => false
      t.datetime "created_at",                                   :null => false
      t.string   "name",         :limit => 50,                    :null => false
      t.boolean  "is_us_state",               :default => true, :null => false
    end
  
    create_table "statuses",  :force => true do |t|
      t.datetime "created_at",               :null => false
      t.string   "name",        :limit => 50, :null => false
    end
  
    create_table "tags",  :force => true do |t|
      t.string   "name",         :limit => 150, :null => false
      t.datetime "created_at",                :null => false
    end
  
    add_index "tags", ["name"], :name => "UK_Tags_Tag", :unique => true
  
    #Include password and email from aspnet_membership
    create_table "users",  :force => true do |t|
      t.integer  "denomination_id"
      t.datetime "created_at",                                           :null => false
      t.integer  "status_id"
      t.string   "first_name",         :limit => 50
      t.string   "last_name",          :limit => 50
      t.string   "phone",          :limit => 20
      t.string   "alt_phone",       :limit => 20
      t.string   "other_denomination", :limit => 50
      t.string   "postal_code",        :limit => 20
      t.datetime "date_of_birth"
      t.boolean  "is_age_verified",                                         :null => false
      t.boolean  "is_tos_read",                                             :null => false
      t.string   "display_name",       :limit => 128
      t.string   "verification_code",  :limit => 16
      t.datetime "verified_at"
      t.string   "password",                               :limit => 256,                :null => false
      t.string   "password_salt",                          :limit => 256               
      t.string   "email_address",                          :limit => 512      
      t.string   "crypted_password"
    end
  
    create_table "user_outreach_priorities",  :force => true do |t|
      t.integer  "user_id",             :null => false
      t.integer  "outreach_priority_id", :null => false
      t.datetime "created_at",        :null => false
    end
  
    create_table "zip_codes",  :force => true do |t|
      t.string   "zip_code",     :limit => 10,                    :null => false
      t.datetime "created_at",                                 :null => false
      t.string   "city",        :limit => 50,                   :null => false
      t.string   "state",       :limit => 32,                    :null => false
      t.string   "country",     :limit => 3,  :default => "US", :null => false
    end
  
#    create_table "ZipZipMatrix",  :force => true do |t|
#      t.string  "FromZipCode", :limit => 5,                                :null => false
#      t.string  "ToZipCode",   :limit => 5,                                :null => false
#      t.decimal "MilesApart",               :precision => 19, :scale => 9, :null => false
#    end
  
#    create_table "aspnet_Applications",  :force => true do |t|
#      t.string "ApplicationName",        :limit => 512,                      :null => false
#      t.string "LoweredApplicationName", :limit => 512,                      :null => false
#      t.string "ApplicationId",          :limit => 16,  :default => "newid", :null => false
#      t.string "Description",            :limit => 512
#    end
#  
#    add_index "aspnet_Applications", ["LoweredApplicationName"], :name => "aspnet_Applications_Index"
#    add_index "aspnet_Applications", ["LoweredApplicationName"], :name => "UQ__aspnet_Applicati__7246E95D", :unique => true
#    add_index "aspnet_Applications", ["ApplicationName"], :name => "UQ__aspnet_Applicati__733B0D96", :unique => true
#  
#    #Moved password and email to users
#    create_table "aspnet_Membership",  :force => true do |t|
#      t.string   "ApplicationId",                          :limit => 16,                 :null => false
#      t.string   "UserId",                                 :limit => 16,                 :null => false
#      t.string   "Password",                               :limit => 256,                :null => false
#      t.integer  "PasswordFormat",                                        :default => 0, :null => false
#      t.string   "PasswordSalt",                           :limit => 256,                :null => false
#      t.string   "MobilePIN",                              :limit => 32
#      t.string   "Email",                                  :limit => 512
#      t.string   "LoweredEmail",                           :limit => 512
#      t.string   "PasswordQuestion",                       :limit => 512
#      t.string   "PasswordAnswer",                         :limit => 256
#      t.boolean  "IsApproved",                                                           :null => false
#      t.boolean  "IsLockedOut",                                                          :null => false
#      t.datetime "CreateDate",                                                           :null => false
#      t.datetime "LastLoginDate",                                                        :null => false
#      t.datetime "LastPasswordChangedDate",                                              :null => false
#      t.datetime "LastLockoutDate",                                                      :null => false
#      t.integer  "FailedPasswordAttemptCount",                                           :null => false
#      t.datetime "FailedPasswordAttemptWindowStart",                                     :null => false
#      t.integer  "FailedPasswordAnswerAttemptCount",                                     :null => false
#      t.datetime "FailedPasswordAnswerAttemptWindowStart",                               :null => false
#      t.text     "Comment"
#    end
#  
#    add_index "aspnet_Membership", ["ApplicationId", "LoweredEmail"], :name => "aspnet_Membership_index"
#  
#    create_table "aspnet_Paths",  :force => true do |t|
#      t.string "ApplicationId", :limit => 16,                       :null => false
#      t.string "PathId",        :limit => 16,  :default => "newid", :null => false
#      t.string "Path",          :limit => 512,                      :null => false
#      t.string "LoweredPath",   :limit => 512,                      :null => false
#    end
#  
#    add_index "aspnet_Paths", ["ApplicationId", "LoweredPath"], :name => "aspnet_Paths_index", :unique => true
#  
#    create_table "aspnet_PersonalizationAllUsers",  :force => true do |t|
#      t.string   "PathId",          :limit => 16, :null => false
#      t.binary   "PageSettings",                  :null => false
#      t.datetime "LastUpdatedDate",               :null => false
#    end
#  
#    create_table "aspnet_PersonalizationPerUser",  :force => true do |t|
#      t.string   "Id",              :limit => 16, :default => "newid", :null => false
#      t.string   "PathId",          :limit => 16
#      t.string   "UserId",          :limit => 16
#      t.binary   "PageSettings",                                       :null => false
#      t.datetime "LastUpdatedDate",                                    :null => false
#    end
#  
#    add_index "aspnet_PersonalizationPerUser", ["PathId", "UserId"], :name => "aspnet_PersonalizationPerUser_index1", :unique => true
#    add_index "aspnet_PersonalizationPerUser", ["UserId", "PathId"], :name => "aspnet_PersonalizationPerUser_ncindex2", :unique => true
#  
#    create_table "aspnet_Profile",  :force => true do |t|
#      t.string   "UserId",               :limit => 16, :null => false
#      t.text     "PropertyNames",                      :null => false
#      t.text     "PropertyValuesString",               :null => false
#      t.binary   "PropertyValuesBinary",               :null => false
#      t.datetime "LastUpdatedDate",                    :null => false
#    end
#  
#    create_table "aspnet_Roles",  :force => true do |t|
#      t.string "ApplicationId",   :limit => 16,                       :null => false
#      t.string "RoleId",          :limit => 16,  :default => "newid", :null => false
#      t.string "RoleName",        :limit => 512,                      :null => false
#      t.string "LoweredRoleName", :limit => 512,                      :null => false
#      t.string "Description",     :limit => 512
#    end
#  
#    add_index "aspnet_Roles", ["ApplicationId", "LoweredRoleName"], :name => "aspnet_Roles_index1", :unique => true
#  
#    create_table "aspnet_SchemaVersions",  :force => true do |t|
#      t.string  "Feature",                 :limit => 256, :null => false
#      t.string  "CompatibleSchemaVersion", :limit => 256, :null => false
#      t.boolean "IsCurrentVersion",                       :null => false
#    end
#  
#    create_table "aspnet_Users",  :force => true do |t|
#      t.string   "ApplicationId",    :limit => 16,                       :null => false
#      t.string   "UserId",           :limit => 16,  :default => "newid", :null => false
#      t.string   "UserName",         :limit => 512,                      :null => false
#      t.string   "LoweredUserName",  :limit => 512,                      :null => false
#      t.string   "MobileAlias",      :limit => 32
#      t.boolean  "IsAnonymous",                     :default => false,   :null => false
#      t.datetime "LastActivityDate",                                     :null => false
#    end
#  
#    add_index "aspnet_Users", ["ApplicationId", "LoweredUserName"], :name => "aspnet_Users_Index", :unique => true
#    add_index "aspnet_Users", ["ApplicationId", "LastActivityDate"], :name => "aspnet_Users_Index2"
#  
#    create_table "aspnet_UsersInRoles",  :force => true do |t|
#      t.string "UserId", :limit => 16, :null => false
#      t.string "RoleId", :limit => 16, :null => false
#    end
#  
#    add_index "aspnet_UsersInRoles", ["RoleId"], :name => "aspnet_UsersInRoles_index"
#  
#    create_table "aspnet_WebEvent_Events",  :force => true do |t|
#      t.string   "EventId",                :limit => 32,                                  :null => false
#      t.datetime "EventTimeUtc",                                                          :null => false
#      t.datetime "EventTime",                                                             :null => false
#      t.string   "EventType",              :limit => 512,                                 :null => false
#      t.integer  "EventSequence",                          :precision => 19, :scale => 0, :null => false
#      t.integer  "EventOccurrence",                        :precision => 19, :scale => 0, :null => false
#      t.integer  "EventCode",                                                             :null => false
#      t.integer  "EventDetailCode",                                                       :null => false
#      t.string   "Message",                :limit => 2048
#      t.string   "ApplicationPath",        :limit => 512
#      t.string   "ApplicationVirtualPath", :limit => 512
#      t.string   "MachineName",            :limit => 512,                                 :null => false
#      t.string   "RequestUrl",             :limit => 2048
#      t.string   "ExceptionType",          :limit => 512
#      t.text     "Details"
#    end
  
#    create_table "sysdiagrams",  :force => true do |t|
#      t.string  "name",         :limit => 256, :null => false
#      t.integer "principal_id",                :null => false
#      t.integer "diagram_id",                  :null => false
#      t.integer "version"
#      t.binary  "definition"
#    end
#  
#    add_index "sysdiagrams", ["principal_id", "name"], :name => "UK_principal_name", :unique => true
  end

  def self.down
    drop_table :address_types
    drop_table :addresses
    drop_table :channel_contents
    drop_table :channel_types
    drop_table :channels
    drop_table :contents
    drop_table :content_details
   # drop_table :content_html_error_log
    drop_table :content_log
    drop_table :content_object_type_groups
    drop_table :content_object_type_players
    drop_table :content_object_types
    drop_table :content_rating_options
    drop_table :content_rating_types
    drop_table :content_ratings
    drop_table :content_sources
    drop_table :content_source_types
    drop_table :content_statuses
    drop_table :content_tags
    drop_table :content_trackings
    drop_table :content_tracking_types
    drop_table :content_uploads
    drop_table :countries
    drop_table :organization_sizes
    drop_table :package_subscription_terms
    drop_table :package_tabs
    drop_table :package_types
    drop_table :packages
    drop_table :permission_types
    drop_table :permissions
    drop_table :players
    drop_table :related_contents
    drop_table :related_content_types
    drop_table :states
    drop_table :statuses
    drop_table :tags
    drop_table :users
    drop_table :user_outreach_priorities
    drop_table :zip_codes
    
  end
end
