# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150626193758) do

  create_table "act_answers", :force => true do |t|
    t.integer  "act_submission_id"
    t.integer  "act_question_id"
    t.integer  "act_choice_id"
    t.boolean  "is_correct"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "short_answer"
    t.boolean  "was_selected"
    t.decimal  "points",            :precision => 3, :scale => 2
    t.integer  "act_assessment_id"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "classroom_id"
    t.integer  "teacher_id"
    t.boolean  "is_calibrated"
  end

  create_table "act_app_options", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "days_til_repeat",                                    :default => 0
    t.integer  "sms_calc_cycle",                                     :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "std_red_threshold",    :precision => 3, :scale => 2
    t.decimal  "sms_h_threshold",      :precision => 3, :scale => 2
    t.decimal  "std_green_threshold",  :precision => 3, :scale => 2
    t.date     "begin_school_year"
    t.integer  "months_for_questions"
    t.string   "standard"
    t.integer  "act_master_id"
    t.integer  "pct_correct_green"
    t.integer  "pct_correct_red"
  end

  create_table "act_assessment_act_questions", :force => true do |t|
    t.integer  "act_assessment_id"
    t.integer  "act_question_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_assessment_act_questions", ["act_assessment_id"], :name => "index_act_assessment_act_questions_on_act_assessment_id"
  add_index "act_assessment_act_questions", ["act_question_id"], :name => "index_act_assessment_act_questions_on_act_question_id"

  create_table "act_assessment_classrooms", :force => true do |t|
    t.integer  "act_assessment_id"
    t.integer  "classroom_id"
    t.integer  "position"
    t.integer  "display_position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_assessment_classrooms", ["act_assessment_id"], :name => "index_act_assessment_classrooms_on_act_assessment_id"
  add_index "act_assessment_classrooms", ["classroom_id"], :name => "index_act_assessment_classrooms_on_classroom_id"

  create_table "act_assessment_score_ranges", :force => true do |t|
    t.integer  "act_assessment_id"
    t.string   "standard"
    t.integer  "lower_score"
    t.integer  "upper_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_master_id"
  end

  add_index "act_assessment_score_ranges", ["act_assessment_id"], :name => "index_act_assessment_score_ranges_on_act_assessment_id"
  add_index "act_assessment_score_ranges", ["act_master_id"], :name => "index_act_assessment_score_ranges_on_act_master_id"
  add_index "act_assessment_score_ranges", ["upper_score"], :name => "index_act_assessment_score_ranges_on_upper_score"

  create_table "act_assessments", :force => true do |t|
    t.string   "name"
    t.integer  "act_subject_id"
    t.integer  "upper_score"
    t.integer  "lower_score"
    t.text     "comment"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.boolean  "is_locked"
    t.integer  "original_assessment_id"
    t.integer  "generation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_calibrated"
    t.boolean  "is_active"
  end

  add_index "act_assessments", ["act_subject_id"], :name => "index_act_assessments_on_act_subject_id"
  add_index "act_assessments", ["is_active"], :name => "index_act_assessments_on_is_active"
  add_index "act_assessments", ["is_calibrated"], :name => "index_act_assessments_on_is_calibrated"
  add_index "act_assessments", ["organization_id"], :name => "index_act_assessments_on_organization_id"
  add_index "act_assessments", ["user_id"], :name => "index_act_assessments_on_user_id"

  create_table "act_bench_act_questions", :force => true do |t|
    t.integer  "act_bench_id"
    t.integer  "act_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "act_bench_act_questions", ["act_bench_id"], :name => "index_act_bench_act_questions_on_act_bench_id"
  add_index "act_bench_act_questions", ["act_question_id"], :name => "index_act_bench_act_questions_on_act_question_id"

  create_table "act_bench_types", :force => true do |t|
    t.string   "name"
    t.string   "standard"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_master_id"
    t.boolean  "for_resource_panel"
    t.boolean  "for_dash_board"
    t.boolean  "for_list"
    t.boolean  "for_static"
    t.string   "long_name"
    t.text     "description"
  end

  create_table "act_benches", :force => true do |t|
    t.integer  "act_subject_id"
    t.integer  "act_standard_id"
    t.integer  "act_score_range_id"
    t.string   "benchmark_type"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "standard"
    t.integer  "co_gle_id"
    t.integer  "act_master_id"
    t.integer  "act_bench_type_id"
  end

  add_index "act_benches", ["act_bench_type_id"], :name => "index_act_benches_on_act_bench_type_id"
  add_index "act_benches", ["act_master_id"], :name => "index_act_benches_on_act_master_id"
  add_index "act_benches", ["act_score_range_id"], :name => "index_act_benches_on_act_score_range_id"
  add_index "act_benches", ["act_standard_id"], :name => "index_act_benches_on_act_standard_id"
  add_index "act_benches", ["act_subject_id"], :name => "index_act_benches_on_act_subject_id"

  create_table "act_bnchmarks", :force => true do |t|
    t.integer  "act_subject_id"
    t.integer  "act_standard_id"
    t.integer  "act_score_range_id"
    t.string   "benchmark_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "organization_id"
  end

  create_table "act_choices", :force => true do |t|
    t.integer  "act_question_id"
    t.text     "choice"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "answer"
    t.boolean  "is_correct",      :default => false
  end

  add_index "act_choices", ["act_question_id"], :name => "index_act_choices_on_act_question_id"
  add_index "act_choices", ["is_correct"], :name => "index_act_choices_on_is_correct"

  create_table "act_genres", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "act_masters", :force => true do |t|
    t.string   "abbrev"
    t.string   "name"
    t.string   "source"
    t.boolean  "is_national"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "act_question_act_score_ranges", :force => true do |t|
    t.integer  "act_question_id"
    t.integer  "act_score_range_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_question_act_score_ranges", ["act_question_id"], :name => "index_act_question_act_score_ranges_on_act_question_id"
  add_index "act_question_act_score_ranges", ["act_score_range_id"], :name => "index_act_question_act_score_ranges_on_act_score_range_id"

  create_table "act_question_act_standards", :force => true do |t|
    t.integer  "act_question_id"
    t.integer  "act_standard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_question_act_standards", ["act_question_id"], :name => "index_act_question_act_standards_on_act_question_id"
  add_index "act_question_act_standards", ["act_standard_id"], :name => "index_act_question_act_standards_on_act_standard_id"

  create_table "act_question_readings", :force => true do |t|
    t.integer  "act_question_id"
    t.text     "reading"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_question_readings", ["act_question_id"], :name => "index_act_question_readings_on_act_question_id"

  create_table "act_questions", :force => true do |t|
    t.integer  "act_subject_id"
    t.integer  "act_standard_id"
    t.integer  "act_score_range_id"
    t.integer  "act_rel_reading_id"
    t.text     "question"
    t.string   "comment"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "question_type"
    t.string   "status"
    t.boolean  "is_locked",            :default => false
    t.integer  "original_question_id"
    t.integer  "generation",           :default => 0
    t.boolean  "is_calibrated"
    t.integer  "co_standard_id"
    t.integer  "co_grade_level_id"
    t.integer  "content_id"
    t.boolean  "is_active"
    t.boolean  "is_enlarged"
  end

  add_index "act_questions", ["act_rel_reading_id"], :name => "index_act_questions_on_act_rel_reading_id"
  add_index "act_questions", ["act_score_range_id"], :name => "index_act_questions_on_act_score_range_id"
  add_index "act_questions", ["act_standard_id"], :name => "index_act_questions_on_act_standard_id"
  add_index "act_questions", ["act_subject_id"], :name => "index_act_questions_on_act_subject_id"
  add_index "act_questions", ["content_id"], :name => "index_act_questions_on_content_id"
  add_index "act_questions", ["is_active"], :name => "index_act_questions_on_is_active"
  add_index "act_questions", ["is_calibrated"], :name => "index_act_questions_on_is_calibrated"
  add_index "act_questions", ["is_locked"], :name => "index_act_questions_on_is_locked"
  add_index "act_questions", ["organization_id"], :name => "index_act_questions_on_organization_id"
  add_index "act_questions", ["user_id"], :name => "index_act_questions_on_user_id"

  create_table "act_rel_reading_act_score_ranges", :force => true do |t|
    t.integer  "act_rel_reading_id"
    t.integer  "act_score_range_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_master_id"
  end

  add_index "act_rel_reading_act_score_ranges", ["act_rel_reading_id"], :name => "index_act_rel_reading_act_score_ranges_on_act_rel_reading_id"
  add_index "act_rel_reading_act_score_ranges", ["act_score_range_id"], :name => "index_act_rel_reading_act_score_ranges_on_act_score_range_id"

  create_table "act_rel_readings", :force => true do |t|
    t.integer  "act_subject_id"
    t.string   "label"
    t.string   "target_score_range"
    t.text     "reading"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_genre_id"
  end

  add_index "act_rel_readings", ["act_genre_id"], :name => "index_act_rel_readings_on_act_genre_id"
  add_index "act_rel_readings", ["act_subject_id"], :name => "index_act_rel_readings_on_act_subject_id"
  add_index "act_rel_readings", ["organization_id"], :name => "index_act_rel_readings_on_organization_id"
  add_index "act_rel_readings", ["user_id"], :name => "index_act_rel_readings_on_user_id"

  create_table "act_score_range_contents", :force => true do |t|
    t.integer  "content_id"
    t.integer  "act_score_range_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_score_range_contents", ["act_score_range_id"], :name => "index_act_score_range_contents_on_act_score_range_id"
  add_index "act_score_range_contents", ["content_id"], :name => "index_act_score_range_contents_on_content_id"

  create_table "act_score_range_topics", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "act_score_range_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_score_range_topics", ["act_score_range_id"], :name => "index_act_score_range_topics_on_act_score_range_id"
  add_index "act_score_range_topics", ["topic_id"], :name => "index_act_score_range_topics_on_topic_id"

  create_table "act_score_ranges", :force => true do |t|
    t.integer  "act_subject_id"
    t.string   "range"
    t.integer  "lower_score"
    t.integer  "upper_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "standard"
    t.integer  "act_master_id"
  end

  add_index "act_score_ranges", ["act_master_id"], :name => "index_act_score_ranges_on_act_master_id"
  add_index "act_score_ranges", ["act_subject_id"], :name => "index_act_score_ranges_on_act_subject_id"
  add_index "act_score_ranges", ["upper_score"], :name => "index_act_score_ranges_on_upper_score"

  create_table "act_snapshots", :force => true do |t|
    t.integer  "user_id"
    t.integer  "act_subject_id"
    t.integer  "last_submission_id"
    t.integer  "current_sms_level"
    t.datetime "last_submission_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "last_submission_sms"
    t.string   "standard"
    t.integer  "act_master_id"
  end

  create_table "act_standard_contents", :force => true do |t|
    t.integer  "content_id"
    t.integer  "act_standard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "act_standard_contents", ["act_standard_id"], :name => "index_act_standard_contents_on_act_standard_id"
  add_index "act_standard_contents", ["content_id"], :name => "index_act_standard_contents_on_content_id"

  create_table "act_standard_topics", :force => true do |t|
    t.integer  "topic_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_standard_id"
  end

  add_index "act_standard_topics", ["act_standard_id"], :name => "index_act_standard_topics_on_act_standard_id"
  add_index "act_standard_topics", ["topic_id"], :name => "index_act_standard_topics_on_topic_id"

  create_table "act_standards", :force => true do |t|
    t.integer  "act_subject_id"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev"
    t.string   "standard"
    t.text     "description"
    t.integer  "act_master_id"
  end

  add_index "act_standards", ["act_master_id"], :name => "index_act_standards_on_act_master_id"
  add_index "act_standards", ["act_subject_id"], :name => "index_act_standards_on_act_subject_id"

  create_table "act_subjects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "act_submission_scores", :force => true do |t|
    t.integer  "act_submission_id"
    t.integer  "act_master_id"
    t.integer  "est_sms"
    t.integer  "final_sms"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "act_submission_scores", ["act_master_id"], :name => "index_act_submission_scores_on_act_master_id"
  add_index "act_submission_scores", ["act_submission_id"], :name => "index_act_submission_scores_on_act_submission_id"

  create_table "act_submission_sms", :force => true do |t|
    t.integer  "act_submission_id"
    t.string   "standard"
    t.integer  "est_sms"
    t.integer  "final_sms"
    t.integer  "upper_score_bound"
    t.integer  "lower_score_bound"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_master_id"
  end

  create_table "act_submissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "act_assessment_id"
    t.integer  "classroom_id"
    t.integer  "teacher_id"
    t.integer  "organization_id"
    t.boolean  "is_final"
    t.datetime "date_finalized"
    t.text     "student_comment"
    t.text     "teacher_comment"
    t.integer  "upper_score_bound"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_subject_id"
    t.integer  "lower_score_bound"
    t.integer  "reviewer_id"
    t.integer  "duration"
    t.boolean  "is_user_dashboarded"
    t.boolean  "is_classroom_dashboarded"
    t.boolean  "is_org_dashboarded"
    t.boolean  "is_auto_finalized"
    t.decimal  "tot_points",               :precision => 3, :scale => 2
    t.integer  "tot_choices"
  end

  add_index "act_submissions", ["act_assessment_id"], :name => "index_act_submissions_on_act_assessment_id"
  add_index "act_submissions", ["act_subject_id"], :name => "index_act_submissions_on_act_subject_id"
  add_index "act_submissions", ["classroom_id"], :name => "index_act_submissions_on_classroom_id"
  add_index "act_submissions", ["is_final"], :name => "index_act_submissions_on_is_final"
  add_index "act_submissions", ["organization_id"], :name => "index_act_submissions_on_organization_id"
  add_index "act_submissions", ["teacher_id"], :name => "index_act_submissions_on_teacher_id"
  add_index "act_submissions", ["user_id"], :name => "index_act_submissions_on_user_id"

  create_table "act_systems", :force => true do |t|
    t.string   "abbrev"
    t.string   "name"
    t.string   "info_source"
    t.boolean  "is_national"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "address_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       :limit => 50, :null => false
  end

  create_table "addresses", :force => true do |t|
    t.integer  "address_type_id",                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "street1",         :limit => 150,                   :null => false
    t.string   "street2",         :limit => 150
    t.string   "city",            :limit => 150,                   :null => false
    t.string   "state",           :limit => 32,                    :null => false
    t.string   "country",         :limit => 3,   :default => "US", :null => false
    t.string   "postal_code",     :limit => 20,                    :null => false
  end

  create_table "app_discussions", :force => true do |t|
    t.integer  "coop_app_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_color", :default => "FFFFFF"
  end

  add_index "app_discussions", ["coop_app_id"], :name => "index_app_discussions_on_coop_app_id"
  add_index "app_discussions", ["organization_id"], :name => "index_app_discussions_on_organization_id"

  create_table "app_method_log_ratings", :force => true do |t|
    t.integer  "app_method_id"
    t.string   "label",         :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bar_color"
    t.string   "measure"
    t.integer  "score"
  end

  add_index "app_method_log_ratings", ["app_method_id"], :name => "index_app_method_log_ratings_on_app_method_id"

  create_table "app_methods", :force => true do |t|
    t.integer  "coop_app_id"
    t.string   "abbrev",            :limit => 4
    t.string   "name",              :limit => 40
    t.text     "description"
    t.boolean  "is_timed"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dashboard_color"
    t.string   "task_name"
    t.string   "back_color_strats"
    t.string   "rating_label"
  end

  add_index "app_methods", ["coop_app_id"], :name => "index_app_methods_on_coop_app_id"

  create_table "applicable_scopes", :force => true do |t|
    t.integer  "authorization_level_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "applicable_scopes", ["authorization_level_id"], :name => "index_applicable_scopes_on_authorization_level_id"

  create_table "authorizable_actions", :force => true do |t|
    t.integer  "authorization_level_id",               :null => false
    t.string   "name",                   :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizable_actions", ["authorization_level_id", "name"], :name => "index_authorizable_actions_on_authorization_level_id_and_name", :unique => true

  create_table "authorization_levels", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name",                        :null => false
    t.string   "description", :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coop_app_id"
    t.text     "explanation"
  end

  add_index "authorization_levels", ["coop_app_id"], :name => "index_authorization_levels_on_coop_app_id"
  add_index "authorization_levels", ["name"], :name => "index_authorization_levels_on_name", :unique => true

  create_table "authorization_levels_roles", :id => false, :force => true do |t|
    t.integer  "authorization_level_id", :null => false
    t.integer  "role_id",                :null => false
    t.datetime "created_at"
  end

  add_index "authorization_levels_roles", ["authorization_level_id", "role_id"], :name => "index_authorization_level_id_and_role_id", :unique => true
  add_index "authorization_levels_roles", ["role_id", "authorization_level_id"], :name => "index_role_id_and_authorization_level_id", :unique => true

  create_table "authorization_levels_users", :id => false, :force => true do |t|
    t.integer  "authorization_level_id", :null => false
    t.integer  "user_id",                :null => false
    t.datetime "created_at"
  end

  add_index "authorization_levels_users", ["authorization_level_id", "user_id"], :name => "index_authorization_level_id_and_user_id", :unique => true
  add_index "authorization_levels_users", ["user_id", "authorization_level_id"], :name => "index_user_id_and_authorization_level_id", :unique => true

  create_table "authorizations", :force => true do |t|
    t.integer  "user_id",                              :null => false
    t.integer  "scope_id"
    t.string   "scope_type",             :limit => 32
    t.integer  "authorization_level_id",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorizations", ["user_id"], :name => "index_authorizations_on_user_id"

  create_table "bios", :force => true do |t|
    t.integer  "bioable_id"
    t.string   "bioable_type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "job_title"
  end

  add_index "bios", ["bioable_type", "bioable_id"], :name => "index_bios_on_bioable_type_and_bioable_id"

  create_table "blog_panels", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_panels_users", :id => false, :force => true do |t|
    t.integer "blog_panel_id"
    t.integer "user_id"
  end

  create_table "blog_post_related_posts", :force => true do |t|
    t.integer  "blog_post_id"
    t.integer  "related_post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blog_post_related_posts", ["blog_post_id"], :name => "index_blog_post_related_posts_on_blog_post_id"
  add_index "blog_post_related_posts", ["related_post_id"], :name => "index_blog_post_related_posts_on_related_post_id"

  create_table "blog_posts", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blog_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.integer  "position"
    t.boolean  "is_active"
    t.boolean  "is_featured"
    t.string   "pov",                  :limit => 32, :default => ""
  end

  add_index "blog_posts", ["blog_id"], :name => "index_blog_posts_on_blog_id"
  add_index "blog_posts", ["is_active"], :name => "index_blog_posts_on_is_active"
  add_index "blog_posts", ["user_id"], :name => "index_blog_posts_on_user_id"

  create_table "blog_types", :force => true do |t|
    t.string   "blog_type"
    t.string   "label"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "blog_types", ["blog_type"], :name => "index_blog_types_on_blog_type"

  create_table "blog_users", :force => true do |t|
    t.integer  "blog_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blog_users", ["blog_id"], :name => "index_blog_users_on_blog_id"
  add_index "blog_users", ["user_id"], :name => "index_blog_users_on_user_id"

  create_table "blogs", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "organization_id"
    t.string   "title"
    t.text     "description"
    t.boolean  "active",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blog_panel_id"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.boolean  "feature",              :default => false
    t.integer  "act_subject_id"
    t.integer  "position"
    t.integer  "blog_type_id"
    t.boolean  "is_commentable"
    t.integer  "coop_app_id"
  end

  add_index "blogs", ["active"], :name => "index_blogs_on_active"
  add_index "blogs", ["blog_panel_id"], :name => "panel"
  add_index "blogs", ["blog_type_id", "organization_id"], :name => "type_org"
  add_index "blogs", ["coop_app_id", "organization_id"], :name => "app_org_type"
  add_index "blogs", ["organization_id", "blog_type_id", "coop_app_id"], :name => "org_type_app"
  add_index "blogs", ["organization_id", "coop_app_id", "blog_type_id"], :name => "org_app_type"

  create_table "channel_contents", :force => true do |t|
    t.integer  "channel_id", :null => false
    t.integer  "content_id", :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "channel_types", :force => true do |t|
    t.string   "name",        :limit => 50,  :null => false
    t.string   "description", :limit => 500
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "channels", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "organization_id",                                      :null => false
    t.integer  "user_id",                                              :null => false
    t.string   "title",                                                :null => false
    t.string   "description",        :limit => 8000
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.boolean  "searchable",                         :default => true, :null => false
    t.datetime "publish_start_date"
    t.datetime "publish_end_date"
    t.string   "type",               :limit => 32,                     :null => false
    t.datetime "last_posted_at"
  end

  add_index "channels", ["organization_id", "type"], :name => "index_channels_on_organization_id_and_type"
  add_index "channels", ["parent_id", "type"], :name => "index_channels_on_parent_id_and_type"

  create_table "classroom_contents", :force => true do |t|
    t.integer  "classroom_id"
    t.integer  "content_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_position", :default => 0
  end

  add_index "classroom_contents", ["classroom_id"], :name => "index_classroom_contents_on_classroom_id"
  add_index "classroom_contents", ["content_id"], :name => "index_classroom_contents_on_content_id"

  create_table "classroom_folders", :force => true do |t|
    t.integer  "classroom_id",                :null => false
    t.integer  "folder_id",                   :null => false
    t.integer  "position",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "classroom_period_users", :force => true do |t|
    t.integer  "classroom_period_id"
    t.integer  "user_id"
    t.boolean  "is_teacher"
    t.boolean  "is_student"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classroom_period_users", ["classroom_period_id", "user_id"], :name => "index_classroom_period_users_on_classroom_period_id_and_user_id"
  add_index "classroom_period_users", ["user_id", "classroom_period_id"], :name => "index_classroom_period_users_on_user_id_and_classroom_period_id"

  create_table "classroom_periods", :force => true do |t|
    t.integer  "classroom_id"
    t.string   "name",          :limit => 32
    t.integer  "week_duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "classroom_periods", ["classroom_id"], :name => "index_classroom_periods_on_classroom_id"

  create_table "classroom_referrals", :force => true do |t|
    t.integer  "classroom_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "classroom_referrals", ["classroom_id"], :name => "index_classroom_referrals_on_classroom_id"
  add_index "classroom_referrals", ["topic_id"], :name => "index_classroom_referrals_on_topic_id"

  create_table "classrooms", :force => true do |t|
    t.string   "course_name"
    t.string   "status",                            :default => "active"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "featured_topic_id"
    t.integer  "user_id"
    t.boolean  "homework_option",                   :default => true
    t.integer  "act_subject_id"
    t.integer  "subject_area_id"
    t.boolean  "is_ifa_enabled"
    t.boolean  "is_ifa_notify"
    t.boolean  "is_ifa_auto_finalize"
    t.boolean  "is_open"
    t.string   "registration_key",     :limit => 8
  end

  add_index "classrooms", ["act_subject_id"], :name => "index_classrooms_on_act_subject_id"
  add_index "classrooms", ["organization_id"], :name => "index_classrooms_on_organization_id"
  add_index "classrooms", ["status"], :name => "index_classrooms_on_status"
  add_index "classrooms", ["subject_area_id"], :name => "index_classrooms_on_subject_area_id"
  add_index "classrooms", ["user_id"], :name => "index_classrooms_on_user_id"

  create_table "client_assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_assignments", ["organization_client_id"], :name => "index_client_assignments_on_organization_client_id"
  add_index "client_assignments", ["user_id"], :name => "index_client_assignments_on_user_id"

  create_table "co_csap_ranges", :force => true do |t|
    t.integer  "act_subject_id"
    t.string   "range"
    t.integer  "lower_score"
    t.integer  "upper_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "co_csap_ranges", ["act_subject_id"], :name => "index_co_csap_ranges_on_act_subject_id"

  create_table "co_gle_evidence_outcomes", :force => true do |t|
    t.integer  "co_gle_id"
    t.string   "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_score_range_id"
  end

  create_table "co_gles", :force => true do |t|
    t.integer  "act_standard_id"
    t.integer  "gle_position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "co_grade_level_id"
    t.text     "skill"
  end

  add_index "co_gles", ["act_standard_id"], :name => "index_co_gles_on_act_standard_id"
  add_index "co_gles", ["co_grade_level_id"], :name => "index_co_gles_on_co_grade_level_id"

  create_table "co_grade_levels", :force => true do |t|
    t.integer  "act_subject_id"
    t.string   "level"
    t.integer  "lower_grade"
    t.integer  "upper_grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "co_standards", :force => true do |t|
    t.integer  "act_subject_id"
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "comments", :force => true do |t|
    t.integer  "blog_post_id"
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name"
    t.string   "user_url"
    t.string   "user_email"
  end

  create_table "content_albums", :force => true do |t|
    t.string   "name"
    t.string   "description",     :limit => 8000
    t.integer  "organization_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "display",                         :default => false
    t.boolean  "accept_upload",                   :default => false
    t.string   "cover",                           :default => ""
  end

  create_table "content_albums_contents", :id => false, :force => true do |t|
    t.integer "content_id"
    t.integer "content_album_id"
  end

  create_table "content_details", :force => true do |t|
    t.string   "content_details_key", :limit => 25,  :null => false
    t.integer  "content_id",                         :null => false
    t.string   "details_value",       :limit => 500
    t.datetime "created_at",                         :null => false
  end

  create_table "content_log", :force => true do |t|
    t.integer  "content_id",                      :null => false
    t.datetime "created_at",                      :null => false
    t.integer  "user_id",                         :null => false
    t.integer  "channel_id",                      :null => false
    t.string   "http_header",     :limit => 4000, :null => false
    t.integer  "organization_id"
    t.integer  "package_id"
  end

  create_table "content_object_type_groups", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at",               :null => false
  end

  create_table "content_object_type_players", :force => true do |t|
    t.string   "content_object_type", :limit => 5,                     :null => false
    t.string   "protocol",            :limit => 5, :default => "HTTP", :null => false
    t.integer  "organization_id",                                      :null => false
    t.integer  "player_id",                                            :null => false
    t.datetime "created_at",                                           :null => false
  end

  create_table "content_object_types", :force => true do |t|
    t.string  "content_object_type",          :limit => 5,                      :null => false
    t.integer "content_object_type_group_id",                                   :null => false
    t.string  "name",                         :limit => 50,                     :null => false
    t.string  "mime_type",                    :limit => 100,                    :null => false
    t.boolean "is_nested_content",                           :default => false, :null => false
  end

  create_table "content_rating_options", :force => true do |t|
    t.integer  "content_rating_type_id",                :null => false
    t.string   "name",                   :limit => 50,  :null => false
    t.string   "description",            :limit => 256
    t.datetime "created_at",                            :null => false
  end

  create_table "content_rating_types", :force => true do |t|
    t.string   "name",        :limit => 50,  :null => false
    t.string   "description", :limit => 150, :null => false
    t.datetime "created_at",                 :null => false
  end

  create_table "content_ratings", :force => true do |t|
    t.integer  "content_rating_option_id", :null => false
    t.datetime "created_at",               :null => false
  end

  create_table "content_resource_types", :force => true do |t|
    t.string   "name",       :limit => 50,  :null => false
    t.string   "descript",   :limit => 150, :null => false
    t.datetime "created_at",                :null => false
  end

  create_table "content_source_types", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at",               :null => false
  end

  create_table "content_sources", :force => true do |t|
    t.integer  "source_type_id",                :null => false
    t.string   "source_value",   :limit => 500, :null => false
    t.datetime "created_at",                    :null => false
  end

  create_table "content_statuses", :force => true do |t|
    t.string   "name",        :limit => 50,  :null => false
    t.string   "description", :limit => 500, :null => false
    t.datetime "created_at",                 :null => false
  end

  create_table "content_tags", :force => true do |t|
    t.integer  "tag_id",     :null => false
    t.datetime "created_at", :null => false
  end

  create_table "content_tracking_types", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at",               :null => false
  end

  create_table "content_trackings", :force => true do |t|
    t.integer  "tracking_type_id", :null => false
    t.integer  "content_id",       :null => false
    t.integer  "user_id",          :null => false
    t.datetime "created_at",       :null => false
  end

  create_table "content_upload_sources", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_uploads", :force => true do |t|
    t.integer  "content_id",                          :null => false
    t.string   "title",               :limit => 150,  :null => false
    t.string   "description",         :limit => 4000
    t.datetime "publish_start_date",                  :null => false
    t.datetime "publish_end_date"
    t.string   "source_url",          :limit => 500
    t.string   "file_name",           :limit => 256
    t.string   "path_and_file_name",  :limit => 500
    t.string   "content_object_type", :limit => 5
    t.binary   "content_object"
    t.string   "source_url_protocol", :limit => 30
  end

  create_table "contents", :force => true do |t|
    t.integer  "child_content_id"
    t.integer  "related_content_type_id"
    t.integer  "content_status_id",                                                   :null => false
    t.string   "title",                            :limit => 150,                     :null => false
    t.string   "description",                      :limit => 4000
    t.integer  "organization_id",                                                     :null => false
    t.integer  "user_id",                                                             :null => false
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.boolean  "mature_content",                                   :default => false, :null => false
    t.boolean  "user_rating_enabled",                              :default => false, :null => false
    t.datetime "publish_start_date",                                                  :null => false
    t.datetime "publish_end_date"
    t.string   "source_url",                       :limit => 500
    t.string   "file_name",                        :limit => 256
    t.string   "source_file_file_name",            :limit => 500
    t.binary   "content_object"
    t.integer  "package_id"
    t.string   "source_url_protocol",              :limit => 30
    t.string   "source_file_content_type",         :limit => 128
    t.integer  "source_file_file_size"
    t.integer  "content_object_type_id"
    t.string   "caption"
    t.integer  "duration"
    t.string   "source_name"
    t.string   "creator_name"
    t.string   "star_performer"
    t.string   "series",                           :limit => 1000
    t.string   "source_file_preview_file_name"
    t.string   "source_file_preview_content_type"
    t.integer  "source_file_preview_file_size"
    t.boolean  "pending",                                          :default => false
    t.integer  "content_upload_source_id",                         :default => 1
    t.boolean  "terms_of_service"
    t.boolean  "is_delete",                                        :default => false
    t.integer  "updated_by"
    t.string   "subject_area_old"
    t.string   "resource_type"
    t.integer  "act_subject_id"
    t.integer  "subject_area_id"
    t.string   "target_score_range"
    t.integer  "content_resource_type_id"
  end

  add_index "contents", ["act_subject_id"], :name => "index_contents_on_act_subject_id"
  add_index "contents", ["content_resource_type_id"], :name => "index_contents_on_content_resource_type_id"
  add_index "contents", ["organization_id"], :name => "index_contents_on_organization_id"
  add_index "contents", ["subject_area_id"], :name => "index_contents_on_subject_area_id"
  add_index "contents", ["user_id"], :name => "index_contents_on_user_id"

  create_table "coop_app_content_resource_types", :force => true do |t|
    t.integer  "coop_app_id"
    t.integer  "content_resource_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coop_app_content_resource_types", ["coop_app_id"], :name => "index_coop_app_content_resource_types_on_coop_app_id"

  create_table "coop_app_organizations", :force => true do |t|
    t.integer  "coop_app_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_owner"
    t.boolean  "is_selected",                   :default => false, :null => false
    t.boolean  "is_allowed",                    :default => true,  :null => false
    t.string   "alt_name",        :limit => 50
    t.string   "alt_abbrev",      :limit => 6
    t.integer  "provider_id"
  end

  add_index "coop_app_organizations", ["coop_app_id", "organization_id"], :name => "app_org"
  add_index "coop_app_organizations", ["organization_id", "coop_app_id"], :name => "org_app"
  add_index "coop_app_organizations", ["organization_id", "provider_id", "coop_app_id"], :name => "org_provider_app"
  add_index "coop_app_organizations", ["provider_id", "coop_app_id", "organization_id"], :name => "provider_app_org"
  add_index "coop_app_organizations", ["provider_id", "organization_id", "coop_app_id"], :name => "provider_org_app"

  create_table "coop_app_rates", :force => true do |t|
    t.integer  "coop_app_id"
    t.string   "pay_class"
    t.string   "pay_period"
    t.integer  "class_max"
    t.integer  "class_min"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "pay",                :precision => 7, :scale => 2
    t.integer  "coop_group_code_id"
    t.boolean  "is_default"
  end

  create_table "coop_app_resources", :force => true do |t|
    t.integer  "coop_app_id"
    t.integer  "organization_id"
    t.integer  "content_id"
    t.boolean  "is_featured"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coop_app_resources", ["content_id"], :name => "index_coop_app_resources_on_content_id"
  add_index "coop_app_resources", ["coop_app_id"], :name => "index_coop_app_resources_on_coop_app_id"
  add_index "coop_app_resources", ["organization_id", "coop_app_id"], :name => "org_app"

  create_table "coop_app_resources_subjects", :force => true do |t|
    t.integer  "coop_app_id"
    t.integer  "subject_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coop_app_resources_subjects", ["coop_app_id"], :name => "index_coop_app_resources_subjects_on_coop_app_id"
  add_index "coop_app_resources_subjects", ["subject_area_id"], :name => "index_coop_app_resources_subjects_on_subject_area_id"

  create_table "coop_apps", :force => true do |t|
    t.string   "name"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_available"
    t.integer  "owner_id"
    t.boolean  "is_beta"
    t.boolean  "is_folderable",   :default => false
    t.boolean  "user_enableable", :default => true
    t.boolean  "is_blogable",     :default => false
  end

  add_index "coop_apps", ["owner_id"], :name => "index_coop_apps_on_owner_id"

  create_table "coop_group_codes", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string   "code",       :limit => 3,  :null => false
    t.datetime "created_at",               :null => false
    t.string   "name",       :limit => 50, :null => false
  end

  create_table "default_package_roles", :force => true do |t|
    t.integer  "package_id", :null => false
    t.integer  "role_id",    :null => false
    t.datetime "created_at", :null => false
  end

  create_table "discussions", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "organization_id",                                        :null => false
    t.integer  "user_id",                                                :null => false
    t.string   "comment",             :limit => 8000
    t.datetime "last_posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "suspended_at"
    t.integer  "suspended_by"
    t.integer  "delete_user"
    t.integer  "discussionable_id"
    t.string   "discussionable_type"
    t.boolean  "is_delete",                           :default => false
    t.boolean  "is_suspended",                        :default => false
  end

  add_index "discussions", ["organization_id"], :name => "index_discussions_on_organization_id"

  create_table "dle_coach_assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "teacher_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dle_coach_assignments", ["teacher_id"], :name => "index_dle_coach_assignments_on_teacher_id"
  add_index "dle_coach_assignments", ["user_id"], :name => "index_dle_coach_assignments_on_coach_id"

  create_table "dle_cycle_orgs", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "dle_cycle_id"
    t.integer  "tlt_survey_type_id"
    t.boolean  "is_output"
    t.string   "output_label"
    t.boolean  "is_targets"
    t.boolean  "is_actual"
    t.boolean  "is_attachable"
    t.string   "attach_label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dle_cycle_orgs", ["dle_cycle_id"], :name => "index_dle_cycle_orgs_on_dle_cycle_id"
  add_index "dle_cycle_orgs", ["organization_id"], :name => "index_dle_cycle_orgs_on_organization_id"
  add_index "dle_cycle_orgs", ["tlt_survey_type_id"], :name => "index_dle_cycle_orgs_on_tlt_survey_id"

  create_table "dle_cycles", :force => true do |t|
    t.integer  "stage"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_output"
    t.boolean  "is_targets"
    t.boolean  "is_actual"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev",             :limit => 5
    t.text     "purpose"
    t.boolean  "is_attachable"
    t.string   "output_label"
    t.string   "attach_label"
    t.integer  "tlt_survey_type_id"
  end

  create_table "dle_metrics", :force => true do |t|
    t.string   "abbrev",     :limit => 5
    t.string   "name"
    t.string   "purpose"
    t.string   "units"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "prereq",     :limit => 75
  end

  create_table "dle_org_options", :force => true do |t|
    t.integer  "organization_id"
    t.boolean  "is_coach_enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dle_resources", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "content_id"
    t.boolean  "is_featured"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dle_resources", ["content_id"], :name => "index_dle_resources_on_content_id"
  add_index "dle_resources", ["organization_id"], :name => "index_dle_resources_on_organization_id"

  create_table "dwls", :force => true do |t|
    t.string "name", :limit => 50
  end

  create_table "elt_activity_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "elt_case_indicators", :force => true do |t|
    t.integer  "elt_case_id"
    t.integer  "elt_indicator_id"
    t.integer  "rubric_id"
    t.text     "evidence"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
  end

  add_index "elt_case_indicators", ["elt_case_id"], :name => "index_elt_case_indicators_on_elt_case_id"
  add_index "elt_case_indicators", ["elt_indicator_id"], :name => "index_elt_case_indicators_on_elt_indicator_id"
  add_index "elt_case_indicators", ["rubric_id", "elt_case_id"], :name => "rubric_case"
  add_index "elt_case_indicators", ["rubric_id", "elt_indicator_id"], :name => "rubric_indicator"

  create_table "elt_case_notes", :force => true do |t|
    t.integer  "elt_case_id"
    t.integer  "elt_element_id"
    t.string   "user_name"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_case_notes", ["elt_case_id"], :name => "index_elt_case_notes_on_elt_case_id"
  add_index "elt_case_notes", ["elt_element_id"], :name => "index_elt_case_notes_on_elt_element_id"

  create_table "elt_cases", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "reviewer_id"
    t.string   "user_name"
    t.string   "reviewer_name"
    t.date     "submit_date"
    t.boolean  "is_submitted",    :default => false
    t.date     "finalize_date"
    t.boolean  "is_final",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "elt_type_id"
    t.string   "name"
    t.string   "object_name"
    t.integer  "classroom_id"
    t.integer  "subject_area_id"
    t.integer  "grade_level_id"
    t.integer  "elt_cycle_id",                       :null => false
  end

  add_index "elt_cases", ["classroom_id"], :name => "index_elt_cases_on_classroom_id"
  add_index "elt_cases", ["elt_cycle_id", "grade_level_id"], :name => "cycle_gradelevel"
  add_index "elt_cases", ["elt_cycle_id", "user_id"], :name => "cycle_user"
  add_index "elt_cases", ["elt_type_id", "organization_id", "user_id"], :name => "element_type_org_user"
  add_index "elt_cases", ["grade_level_id"], :name => "index_elt_cases_on_grade_level_id"
  add_index "elt_cases", ["organization_id", "elt_cycle_id", "elt_type_id"], :name => "organization_cycle_activity"
  add_index "elt_cases", ["organization_id", "elt_cycle_id"], :name => "organization_cycle"
  add_index "elt_cases", ["organization_id", "elt_type_id", "user_id"], :name => "element_org_type_user"
  add_index "elt_cases", ["reviewer_id"], :name => "index_elt_cases_on_reviewer_id"
  add_index "elt_cases", ["subject_area_id"], :name => "index_elt_cases_on_subject_area_id"
  add_index "elt_cases", ["user_id"], :name => "index_elt_cases_on_user_id"

  create_table "elt_cycle_activities", :force => true do |t|
    t.integer  "elt_cycle_id"
    t.integer  "elt_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_cycle_activities", ["elt_cycle_id", "elt_type_id"], :name => "cycle_activity"
  add_index "elt_cycle_activities", ["elt_type_id", "elt_cycle_id"], :name => "activity_cycle"

  create_table "elt_cycle_summaries", :force => true do |t|
    t.integer  "elt_cycle_id"
    t.integer  "elt_indicator_id"
    t.integer  "elt_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score_count",      :default => 0
    t.integer  "score_total",      :default => 0
  end

  add_index "elt_cycle_summaries", ["elt_cycle_id", "elt_indicator_id", "elt_type_id"], :name => "cycle_indicator_activity"
  add_index "elt_cycle_summaries", ["elt_indicator_id", "elt_cycle_id", "elt_type_id"], :name => "indicator_cycle_activity"
  add_index "elt_cycle_summaries", ["elt_type_id", "elt_indicator_id", "elt_cycle_id"], :name => "activity_indicator_cycle"

  create_table "elt_cycles", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name",               :limit => 64
    t.boolean  "is_active",                         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_delete",                         :default => false
    t.date     "survey_school_date"
    t.date     "begin_date"
    t.date     "end_date"
    t.text     "abbrev",             :limit => 255
    t.integer  "elt_framework_id"
  end

  add_index "elt_cycles", ["elt_framework_id"], :name => "index_elt_cycles_on_elt_framework_id"
  add_index "elt_cycles", ["organization_id"], :name => "index_elt_cycles_on_organization_id"

  create_table "elt_elements", :force => true do |t|
    t.string   "name",              :limit => 50
    t.string   "abbrev",            :limit => 5
    t.integer  "position"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "form_background",   :limit => 7
    t.string   "i_form_background", :limit => 7
    t.string   "e_font_color",      :limit => 7
    t.integer  "organization_id"
    t.boolean  "is_active"
    t.integer  "elt_framework_id"
  end

  add_index "elt_elements", ["elt_framework_id"], :name => "index_elt_elements_on_elt_framework_id"
  add_index "elt_elements", ["organization_id"], :name => "index_elt_elements_on_organization_id"

  create_table "elt_frameworks", :force => true do |t|
    t.integer  "organization_id"
    t.string   "abbrev",          :limit => 8
    t.string   "name",            :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_frameworks", ["organization_id"], :name => "index_elt_frameworks_on_organization_id"

  create_table "elt_indicator_lookfors", :force => true do |t|
    t.integer  "elt_indicator_id"
    t.integer  "position"
    t.string   "lookfor"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_indicator_lookfors", ["elt_indicator_id"], :name => "indicator_id"

  create_table "elt_indicators", :force => true do |t|
    t.integer  "elt_element_id"
    t.integer  "position"
    t.integer  "weight"
    t.text     "indicator"
    t.boolean  "is_active",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ind_num"
    t.integer  "elt_type_id"
    t.integer  "parent_id"
  end

  add_index "elt_indicators", ["elt_element_id", "elt_type_id"], :name => "element_type"
  add_index "elt_indicators", ["elt_type_id", "elt_element_id"], :name => "type_element"
  add_index "elt_indicators", ["parent_id"], :name => "index_elt_indicators_on_parent_id"

  create_table "elt_org_options", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "owner_org_id"
    t.integer  "elt_cycle_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "elt_framework_id"
  end

  add_index "elt_org_options", ["elt_cycle_id", "organization_id"], :name => "cycle_org"
  add_index "elt_org_options", ["elt_framework_id"], :name => "index_elt_org_options_on_elt_framework_id"
  add_index "elt_org_options", ["organization_id", "elt_cycle_id"], :name => "org_cycle"
  add_index "elt_org_options", ["organization_id", "owner_org_id", "elt_cycle_id"], :name => "org_ownerorg_cycle"
  add_index "elt_org_options", ["owner_org_id", "organization_id", "elt_cycle_id"], :name => "ownerorg_org_cycle"

  create_table "elt_plan_actions", :force => true do |t|
    t.integer  "scope_id"
    t.string   "scope_type",  :limit => 32
    t.integer  "elt_plan_id",               :null => false
    t.integer  "rubric_id"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_plan_actions", ["elt_plan_id", "scope_type", "scope_id"], :name => "plan_scope"
  add_index "elt_plan_actions", ["rubric_id", "elt_plan_id"], :name => "rubric_plan"
  add_index "elt_plan_actions", ["scope_type", "scope_id", "elt_plan_id"], :name => "scope_plan"

  create_table "elt_plan_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "abbrev",          :limit => 8
    t.string   "name",            :limit => 32
    t.boolean  "is_active",                     :default => true
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_plan_types", ["organization_id"], :name => "organization"

  create_table "elt_plans", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "elt_cycle_id"
    t.boolean  "is_open",         :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_plans", ["elt_cycle_id", "organization_id"], :name => "cycle_organization"
  add_index "elt_plans", ["organization_id", "elt_cycle_id"], :name => "organization_cycle"

  create_table "elt_related_indicators", :force => true do |t|
    t.integer  "elt_indicator_id"
    t.integer  "related_indicator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_related_indicators", ["elt_indicator_id", "related_indicator_id"], :name => "index_indicator_id", :unique => true
  add_index "elt_related_indicators", ["related_indicator_id", "elt_indicator_id"], :name => "index_related_id", :unique => true

  create_table "elt_rubric_criterias", :force => true do |t|
    t.integer  "elt_rubric_id"
    t.integer  "position"
    t.string   "description",   :limit => 512
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "elt_rubric_criterias", ["elt_rubric_id"], :name => "index_elt_rubric_criterias_on_elt_rubric_id"

  create_table "elt_rubrics", :force => true do |t|
    t.string   "name",               :limit => 15
    t.integer  "score"
    t.string   "criteria_condition", :limit => 512
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev",             :limit => 1
    t.integer  "elt_type_id"
  end

  add_index "elt_rubrics", ["elt_type_id"], :name => "index_elt_rubrics_on_elt_type_id"

  create_table "elt_types", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",             :default => 1
    t.boolean  "use_rubric",           :default => false
    t.integer  "elt_activity_type_id"
    t.boolean  "is_master",            :default => false
    t.boolean  "provider_only",        :default => false
    t.boolean  "tag_subject",          :default => false
    t.boolean  "tag_grade",            :default => false
    t.integer  "rubric_id"
    t.boolean  "is_reportable",        :default => true
    t.integer  "elt_framework_id"
  end

  add_index "elt_types", ["elt_framework_id"], :name => "index_elt_types_on_elt_framework_id"
  add_index "elt_types", ["organization_id"], :name => "type_organization"
  add_index "elt_types", ["rubric_id"], :name => "index_elt_types_on_rubric_id"

  create_table "event_log_types", :force => true do |t|
    t.string "name", :limit => 50, :null => false
  end

  create_table "event_logs", :force => true do |t|
    t.integer  "event_log_type_id"
    t.integer  "user_id"
    t.integer  "channel_id"
    t.integer  "content_id"
    t.datetime "created_at",                       :null => false
    t.string   "event_data",        :limit => 500
  end

  create_table "folder_folderables", :force => true do |t|
    t.integer  "folder_id"
    t.integer  "folderable_id"
    t.string   "folderable_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "folder_folderables", ["folder_id"], :name => "folder"
  add_index "folder_folderables", ["folderable_id"], :name => "folderable"
  add_index "folder_folderables", ["folderable_type", "folderable_id"], :name => "folderable_type"

  create_table "folder_positions", :force => true do |t|
    t.integer  "folder_id"
    t.integer  "scope_id"
    t.string   "scope_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "folder_positions", ["folder_id"], :name => "folder"
  add_index "folder_positions", ["scope_id"], :name => "scope"
  add_index "folder_positions", ["scope_type", "scope_id"], :name => "scope_type"

  create_table "folders", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coop_app_id"
    t.integer  "organization_id"
  end

  add_index "folders", ["coop_app_id", "organization_id"], :name => "app_organization"
  add_index "folders", ["organization_id", "coop_app_id"], :name => "organization_app"

  create_table "fundraising_campaigns", :force => true do |t|
    t.string   "name"
    t.string   "description",         :limit => 8000
    t.integer  "organization_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "merchant_account_id"
    t.decimal  "goal_amount",                         :precision => 12, :scale => 2, :default => 0.0
    t.decimal  "suggested_amount",                    :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grade_levels", :force => true do |t|
    t.integer  "organization_type_id"
    t.string   "name"
    t.integer  "level"
    t.string   "abbrev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grade_levels", ["organization_type_id"], :name => "index_grade_levels_on_organization_type_id"

  create_table "homeworks", :force => true do |t|
    t.integer  "classroom_id"
    t.string   "title"
    t.integer  "user_id"
    t.integer  "teacher_id"
    t.text     "comments"
    t.string   "homework_file_name"
    t.string   "homework_content_type"
    t.integer  "content_object_type_id"
    t.integer  "homework_file_size"
    t.datetime "first_viewed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "topic_title"
    t.boolean  "is_deleted"
  end

  add_index "homeworks", ["classroom_id"], :name => "index_homeworks_on_classroom_id"
  add_index "homeworks", ["teacher_id"], :name => "index_homeworks_on_teacher_id"
  add_index "homeworks", ["user_id"], :name => "index_homeworks_on_user_id"

  create_table "ifa_classroom_options", :force => true do |t|
    t.integer  "classroom_id"
    t.boolean  "is_ifa_notify"
    t.boolean  "is_ifa_auto_finalize"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_subject_id"
    t.integer  "act_master_id"
    t.boolean  "is_calibrated"
    t.boolean  "is_user_filtered"
    t.integer  "max_score_filter"
    t.integer  "days_til_repeat"
  end

  add_index "ifa_classroom_options", ["classroom_id"], :name => "index_ifa_classroom_options_on_classroom_id", :unique => true

  create_table "ifa_dashboard_cells", :force => true do |t|
    t.integer  "ifa_dashboard_id"
    t.integer  "act_master_id"
    t.integer  "act_score_range_id"
    t.integer  "act_standard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finalized_answers"
    t.integer  "calibrated_answers"
    t.text     "finalized_hover"
    t.text     "calibrated_hover"
    t.decimal  "fin_points",         :precision => 7, :scale => 2
    t.decimal  "cal_points",         :precision => 7, :scale => 2
  end

  create_table "ifa_dashboard_sms_scores", :force => true do |t|
    t.integer  "ifa_dashboard_id"
    t.integer  "act_master_id"
    t.integer  "score_range_min"
    t.integer  "score_range_max"
    t.integer  "sms_finalized"
    t.integer  "sms_calibrated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "baseline_score"
  end

  create_table "ifa_dashboards", :force => true do |t|
    t.integer  "ifa_dashboardable_id"
    t.string   "ifa_dashboardable_type"
    t.integer  "organization_id"
    t.date     "period_end"
    t.integer  "act_subject_id"
    t.integer  "assessments_taken"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finalized_assessments"
    t.integer  "calibrated_assessments"
    t.integer  "finalized_answers"
    t.integer  "calibrated_answers"
    t.integer  "finalized_duration"
    t.integer  "calibrated_duration"
    t.decimal  "fin_points",             :precision => 7, :scale => 2
    t.decimal  "cal_points",             :precision => 7, :scale => 2
    t.decimal  "cal_submission_points",  :precision => 7, :scale => 2
    t.integer  "cal_submission_answers"
  end

  create_table "ifa_org_option_act_masters", :force => true do |t|
    t.integer  "ifa_org_option_id"
    t.integer  "act_master_id"
    t.boolean  "is_default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ifa_org_options", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "days_til_repeat"
    t.integer  "sms_calc_cycle"
    t.decimal  "sms_h_threshold",      :precision => 3, :scale => 2
    t.integer  "pct_correct_red"
    t.integer  "pct_correct_green"
    t.integer  "months_for_questions"
    t.date     "begin_school_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ifa_org_options", ["organization_id"], :name => "index_ifa_org_options_on_organization_id", :unique => true

  create_table "ifa_question_logs", :force => true do |t|
    t.integer  "act_question_id"
    t.integer  "act_assessment_id"
    t.integer  "act_submission_id"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "classroom_id"
    t.integer  "teacher_id"
    t.integer  "act_subject_id"
    t.date     "date_taken"
    t.boolean  "is_calibrated"
    t.integer  "choices"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "earned_points",     :precision => 3, :scale => 2
    t.date     "period_end"
    t.integer  "grade_level"
    t.integer  "csap"
  end

  add_index "ifa_question_logs", ["act_question_id", "act_submission_id"], :name => "index_ifa_question_logs_on_act_question_id_and_act_submission_id"
  add_index "ifa_question_logs", ["act_submission_id", "act_question_id"], :name => "index_ifa_question_logs_on_act_submission_id_and_act_question_id"
  add_index "ifa_question_logs", ["csap"], :name => "index_ifa_question_logs_on_csap"
  add_index "ifa_question_logs", ["grade_level"], :name => "index_ifa_question_logs_on_grade_level"

  create_table "ifa_question_performances", :force => true do |t|
    t.integer  "act_question_id"
    t.integer  "act_score_range_id"
    t.integer  "students"
    t.integer  "answers"
    t.decimal  "points",                     :precision => 8, :scale => 2
    t.integer  "calibrated_students"
    t.integer  "calibrated_student_answers"
    t.decimal  "calibrated_student_points",  :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "baseline_students"
    t.integer  "baseline_answers"
    t.decimal  "baseline_points",            :precision => 8, :scale => 2
  end

  add_index "ifa_question_performances", ["act_question_id"], :name => "index_ifa_question_performances_on_act_question_id"
  add_index "ifa_question_performances", ["act_score_range_id"], :name => "index_ifa_question_performances_on_act_score_range_id"

  create_table "ifa_student_levels", :force => true do |t|
    t.integer  "act_question_id"
    t.integer  "act_master_id"
    t.integer  "user_id"
    t.integer  "mastery_level"
    t.integer  "calibrated_mastery_level"
    t.integer  "choices"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_submission_id"
    t.date     "submission_date"
    t.decimal  "earned_points",            :precision => 3, :scale => 2
  end

  create_table "ifa_user_baseline_scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "act_master_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_subject_id"
  end

  add_index "ifa_user_baseline_scores", ["act_master_id"], :name => "index_ifa_user_baseline_scores_on_act_master_id"
  add_index "ifa_user_baseline_scores", ["act_subject_id"], :name => "index_ifa_user_baseline_scores_on_act_subject_id"
  add_index "ifa_user_baseline_scores", ["user_id"], :name => "index_ifa_user_baseline_scores_on_user_id"

  create_table "ifa_user_options", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "is_calibrated"
    t.integer  "act_master_id"
    t.integer  "act_rel_reading_id"
    t.integer  "act_score_range_id"
    t.integer  "act_standard_id"
    t.boolean  "is_user_filtered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_org_filtered"
    t.boolean  "is_classroom_filtered"
    t.boolean  "is_student_filtered"
    t.boolean  "is_colleague_filtered"
    t.date     "beginning_period"
  end

  add_index "ifa_user_options", ["user_id"], :name => "index_ifa_user_options_on_user_id", :unique => true

  create_table "ista_activities", :force => true do |t|
    t.integer  "ista_group_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ista_step_id"
    t.integer  "seq_num"
    t.boolean  "is_active"
  end

  add_index "ista_activities", ["ista_group_id"], :name => "index_ista_activities_on_ista_group_id"
  add_index "ista_activities", ["ista_step_id"], :name => "index_ista_activities_on_ista_step_id"

  create_table "ista_case_allocations", :force => true do |t|
    t.integer  "activity_id"
    t.string   "activity_type"
    t.integer  "ista_case_id",                                :null => false
    t.integer  "ista_step_id",                                :null => false
    t.integer  "minsweek",                     :default => 0
    t.integer  "hrsyear",                      :default => 0
    t.string   "comment",       :limit => 250
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ista_group_id"
    t.string   "name"
  end

  add_index "ista_case_allocations", ["ista_case_id"], :name => "index_ista_case_allocations_on_ista_case_id"
  add_index "ista_case_allocations", ["ista_group_id"], :name => "index_ista_case_allocations_on_ista_group_id"
  add_index "ista_case_allocations", ["ista_step_id"], :name => "index_ista_case_allocations_on_ista_step_id"

  create_table "ista_cases", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "ista_step_id"
    t.string   "title"
    t.integer  "case_students"
    t.boolean  "is_active",                                     :default => false
    t.boolean  "is_final",                                      :default => false
    t.date     "final_date"
    t.boolean  "is_archived",                                   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "hrsday_std",      :precision => 4, :scale => 2
    t.decimal  "hrsday_er",       :precision => 4, :scale => 2
    t.decimal  "hrsday_ls",       :precision => 4, :scale => 2
    t.decimal  "daysweek",        :precision => 2, :scale => 1
    t.decimal  "daysyear_std",    :precision => 4, :scale => 1
    t.decimal  "daysyear_er",     :precision => 4, :scale => 1
    t.decimal  "daysyear_ls",     :precision => 4, :scale => 1
    t.decimal  "case_teachers",   :precision => 4, :scale => 1, :default => 0.0
  end

  add_index "ista_cases", ["ista_step_id"], :name => "index_ista_cases_on_ista_step_id"
  add_index "ista_cases", ["organization_id"], :name => "index_ista_cases_on_organization_id"
  add_index "ista_cases", ["user_id"], :name => "index_ista_cases_on_user_id"

  create_table "ista_groups", :force => true do |t|
    t.string   "name"
    t.string   "subject_list"
    t.string   "level_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_1"
    t.string   "background_2"
    t.string   "group_code",   :limit => 1
    t.integer  "level"
  end

  create_table "ista_steps", :force => true do |t|
    t.integer  "step_number"
    t.string   "name"
    t.boolean  "is_active"
    t.string   "background"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name"
  end

  create_table "itl_belt_ranks", :force => true do |t|
    t.string   "rank"
    t.integer  "rank_score"
    t.string   "image"
    t.text     "criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filter_select"
    t.string   "filter_image"
  end

  create_table "itl_blackbelts", :force => true do |t|
    t.integer  "content_id"
    t.integer  "tlt_session_id"
    t.integer  "observer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_blackbelts", ["content_id", "tlt_session_id"], :name => "index_itl_blackbelts_on_content_id_and_tlt_session_id", :unique => true
  add_index "itl_blackbelts", ["tlt_session_id", "content_id"], :name => "index_itl_blackbelts_on_tlt_session_id_and_content_id", :unique => true

  create_table "itl_org_option_app_methods", :force => true do |t|
    t.integer  "itl_org_option_id"
    t.integer  "app_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_org_option_app_methods", ["app_method_id", "itl_org_option_id"], :name => "app_method_org_option"
  add_index "itl_org_option_app_methods", ["itl_org_option_id"], :name => "index_itl_org_option_app_methods_on_itl_org_option_id"

  create_table "itl_org_option_filters", :force => true do |t|
    t.integer  "itl_org_option_id"
    t.integer  "tl_activity_type_task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_org_option_filters", ["itl_org_option_id"], :name => "index_itl_org_option_filters_on_itl_org_option_id"
  add_index "itl_org_option_filters", ["tl_activity_type_task_id", "itl_org_option_id"], :name => "filter_org_option"

  create_table "itl_org_options", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "stat_window"
    t.boolean  "is_concurrent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "schedule_url",        :limit => 250, :default => ""
    t.string   "schedule_label",      :limit => 250, :default => ""
    t.integer  "classroom_period_id"
    t.boolean  "is_belt_ranking"
    t.boolean  "is_thresholds"
    t.integer  "log_display_count"
    t.boolean  "is_conversations"
    t.boolean  "is_teacher_finalize"
  end

  add_index "itl_org_options", ["classroom_period_id"], :name => "index_itl_org_options_on_classroom_period_id"
  add_index "itl_org_options", ["organization_id"], :name => "index_itl_org_options_on_organization_id"

  create_table "itl_strategy_evidences", :force => true do |t|
    t.integer  "tl_activity_type_task_id"
    t.integer  "evidence_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_strategy_evidences", ["evidence_id"], :name => "index_itl_strategy_evidences_on_evidence_id"
  add_index "itl_strategy_evidences", ["tl_activity_type_task_id"], :name => "index_itl_strategy_evidences_on_tl_activity_type_task_id"

  create_table "itl_strategy_thresholds", :force => true do |t|
    t.integer  "tl_activity_type_task_id"
    t.decimal  "max_minutes",              :precision => 5, :scale => 2
    t.string   "max_minutes_msg"
    t.decimal  "min_minutes",              :precision => 5, :scale => 2
    t.string   "min_minutes_msg"
    t.integer  "max_pct"
    t.string   "max_pct_msg"
    t.integer  "min_pct"
    t.string   "min_pct_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_strategy_thresholds", ["tl_activity_type_task_id"], :name => "index_itl_strategy_thresholds_on_tl_activity_type_task_id"

  create_table "itl_summaries", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "subject_area_id"
    t.integer  "organization_type_id"
    t.integer  "observation_count"
    t.integer  "classroom_duration"
    t.integer  "observation_duration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "classroom_id"
    t.date     "yr_mnth_of"
    t.integer  "itl_belt_rank_id"
  end

  add_index "itl_summaries", ["classroom_id", "yr_mnth_of"], :name => "classroom_yrmnthof"
  add_index "itl_summaries", ["classroom_id"], :name => "classroom_yrmnth"
  add_index "itl_summaries", ["itl_belt_rank_id", "organization_id", "subject_area_id", "yr_mnth_of"], :name => "belt_org_subj_yrmnth"
  add_index "itl_summaries", ["organization_id", "subject_area_id", "yr_mnth_of"], :name => "org_subject_month"
  add_index "itl_summaries", ["organization_id", "subject_area_id"], :name => "org_period_subject"
  add_index "itl_summaries", ["organization_id", "yr_mnth_of", "subject_area_id"], :name => "org_yrmnthof_subject"
  add_index "itl_summaries", ["organization_id", "yr_mnth_of"], :name => "org_month"
  add_index "itl_summaries", ["organization_type_id", "subject_area_id", "yr_mnth_of"], :name => "orgtype_subject_month"
  add_index "itl_summaries", ["organization_type_id", "subject_area_id"], :name => "orgtype_period_subject"
  add_index "itl_summaries", ["organization_type_id", "yr_mnth_of", "subject_area_id"], :name => "orgtype_yrmnthof_subject"
  add_index "itl_summaries", ["organization_type_id", "yr_mnth_of"], :name => "orgtype_month"
  add_index "itl_summaries", ["subject_area_id", "organization_id"], :name => "user_period_subject_org"

  create_table "itl_summary_strategies", :force => true do |t|
    t.integer  "itl_summary_id"
    t.integer  "tl_activity_type_task_id"
    t.integer  "duration",                 :default => 0
    t.integer  "segments",                 :default => 0
    t.integer  "engage_total",             :default => 0
    t.integer  "engage_segments",          :default => 0
    t.integer  "layer_effect",             :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_summary_strategies", ["itl_summary_id"], :name => "index_itl_summary_strategies_on_itl_summary_id"
  add_index "itl_summary_strategies", ["tl_activity_type_task_id"], :name => "index_itl_summary_strategies_on_tl_activity_type_task_id"

  create_table "itl_template_app_methods", :force => true do |t|
    t.integer  "itl_template_id"
    t.integer  "app_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_template_app_methods", ["app_method_id", "itl_template_id"], :name => "app_method_template"
  add_index "itl_template_app_methods", ["itl_template_id"], :name => "index_itl_template_app_methods_on_itl_template_id"

  create_table "itl_template_filters", :force => true do |t|
    t.integer  "itl_template_id"
    t.integer  "tl_activity_type_task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "itl_template_filters", ["itl_template_id"], :name => "index_itl_template_filters_on_itl_template_id"
  add_index "itl_template_filters", ["tl_activity_type_task_id", "itl_template_id"], :name => "task_template"

  create_table "itl_templates", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name",            :limit => 35
    t.text     "description"
    t.boolean  "is_editable",                   :default => true
    t.boolean  "is_enabled",                    :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_default",                    :default => false
  end

  add_index "itl_templates", ["organization_id"], :name => "index_itl_templates_on_organization_id"

  create_table "merchant_accounts", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "description"
    t.string   "gateway_type"
    t.string   "gateway_partner"
    t.string   "gateway_login"
    t.string   "gateway_password"
    t.string   "gateway_certification_id",          :limit => 128
    t.string   "vat_registration_number",           :limit => 128
    t.boolean  "gateway_ignore_avs",                                                             :default => true
    t.boolean  "gateway_ignore_cvv",                                                             :default => true
    t.decimal  "payment_transaction_fee",                          :precision => 9, :scale => 2, :default => 0.0
    t.decimal  "payment_transaction_discount_rate",                :precision => 9, :scale => 2, :default => 0.0
    t.decimal  "refund_transaction_fee",                           :precision => 9, :scale => 2, :default => 0.0
    t.decimal  "chargeback_transaction_fee",                       :precision => 9, :scale => 2, :default => 0.0
    t.string   "card_statement_name",               :limit => 128
    t.boolean  "visa"
    t.boolean  "master"
    t.boolean  "american_express"
    t.boolean  "discover"
    t.boolean  "diners_club"
    t.boolean  "mastro"
    t.boolean  "jcb"
    t.text     "gateway_pem"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.text     "content"
    t.string   "sender"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "classroom_id"
    t.integer  "sender_id"
  end

  create_table "organization_clients", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "client_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",       :default => true
  end

  add_index "organization_clients", ["client_id"], :name => "index_organization_clients_on_client_id"
  add_index "organization_clients", ["organization_id"], :name => "index_organization_clients_on_organization_id"

  create_table "organization_core_options", :force => true do |t|
    t.integer  "organization_id"
    t.boolean  "register_notify", :default => true
    t.boolean  "content_notify",  :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_core_options", ["organization_id"], :name => "index_organization_core_options_on_organization_id"

  create_table "organization_dle_metrics", :force => true do |t|
    t.integer  "dle_metric_id"
    t.integer  "organization_id"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_relationships", :force => true do |t|
    t.integer  "source_id",                                         :null => false
    t.string   "relationship_type", :limit => 32,                   :null => false
    t.integer  "target_id",                                         :null => false
    t.string   "target_type",       :limit => 32,                   :null => false
    t.boolean  "inclusive",                       :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source_type",       :limit => 32
  end

  add_index "organization_relationships", ["source_id", "relationship_type"], :name => "organization_id_and_relationship_type"

  create_table "organization_sizes", :force => true do |t|
    t.datetime "created_at",                :null => false
    t.string   "description", :limit => 50, :null => false
    t.integer  "value_low"
    t.integer  "value_high"
  end

  create_table "organization_types", :force => true do |t|
    t.integer  "parent_id"
    t.datetime "created_at",                                                 :null => false
    t.string   "name",                      :limit => 50,                    :null => false
    t.string   "template_name"
    t.boolean  "has_size",                                :default => false
    t.boolean  "has_religious_affiliation",               :default => false
    t.boolean  "is_k12"
  end

  create_table "organization_visits", :force => true do |t|
    t.integer  "organization_id",                :null => false
    t.integer  "user_id"
    t.datetime "date_visited",                   :null => false
    t.integer  "visit_year",      :default => 0, :null => false
    t.integer  "visit_month",     :default => 0, :null => false
    t.integer  "visit_day",       :default => 0, :null => false
    t.integer  "visit_hour",      :default => 0, :null => false
    t.integer  "visit_minutes",   :default => 0, :null => false
  end

  add_index "organization_visits", ["date_visited"], :name => "IDX4_OrganizationVisits"
  add_index "organization_visits", ["organization_id", "date_visited"], :name => "IDX3_OrganizationVisits"
  add_index "organization_visits", ["organization_id", "visit_year", "visit_month", "visit_day"], :name => "IDX1_OrganizationVisits"
  add_index "organization_visits", ["visit_year", "visit_month", "visit_day"], :name => "IDX2_OrganizationVisits"

  create_table "organizations", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "organization_type_id",                                       :null => false
    t.string   "name",                      :limit => 200,                   :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
    t.integer  "channel_id"
    t.integer  "religious_affiliation_id"
    t.string   "web_site_url",              :limit => 250
    t.integer  "iwing_tab_id"
    t.integer  "status_id",                                                  :null => false
    t.string   "phone",                     :limit => 20
    t.string   "fax",                       :limit => 20
    t.integer  "organization_size_id"
    t.integer  "package_id"
    t.string   "email_address",             :limit => 256
    t.string   "contact_name"
    t.string   "contact_role"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.integer  "featured_topic_id"
    t.integer  "default_address_id"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.text     "body"
    t.integer  "cause_streaming_source_id",                :default => 1
    t.boolean  "include_information",                      :default => true
    t.integer  "coop_group_code_id"
    t.boolean  "is_default"
    t.string   "nick_name",                                :default => ""
    t.string   "alt_short_name",            :limit => 10
    t.boolean  "display_contact",                          :default => true
  end

  add_index "organizations", ["organization_type_id"], :name => "IDX2_Organizations"
  add_index "organizations", ["religious_affiliation_id"], :name => "IDX1_Organizations"

  create_table "organizations_outreach_priorities", :id => false, :force => true do |t|
    t.integer  "outreach_priority_id", :default => 0, :null => false
    t.integer  "organization_id",      :default => 0, :null => false
    t.datetime "created_at"
  end

  add_index "organizations_outreach_priorities", ["organization_id", "outreach_priority_id"], :name => "index_organization_id_and_outreach_priority_id", :unique => true
  add_index "organizations_outreach_priorities", ["outreach_priority_id", "organization_id"], :name => "index_outreach_priority_id_and_organization_id", :unique => true

  create_table "organizations_users", :id => false, :force => true do |t|
    t.integer  "organization_id", :null => false
    t.integer  "user_id",         :null => false
    t.datetime "created_at",      :null => false
  end

  add_index "organizations_users", ["organization_id", "user_id"], :name => "index_organizations_users_on_organization_id_and_user_id", :unique => true
  add_index "organizations_users", ["user_id", "organization_id"], :name => "index_organizations_users_on_user_id_and_organization_id", :unique => true

  create_table "outreach_priorities", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at",               :null => false
  end

  create_table "outreach_priorities_outreach_priority_groups", :id => false, :force => true do |t|
    t.integer  "outreach_priority_id"
    t.integer  "outreach_priority_group_id"
    t.datetime "create_at"
  end

  create_table "outreach_priorities_topics", :id => false, :force => true do |t|
    t.integer  "outreach_priority_id", :default => 0, :null => false
    t.integer  "topic_id",             :default => 0, :null => false
    t.datetime "created_at"
  end

  add_index "outreach_priorities_topics", ["outreach_priority_id", "topic_id"], :name => "index_outreach_priority_id_and_topic_id", :unique => true
  add_index "outreach_priorities_topics", ["topic_id", "outreach_priority_id"], :name => "index_topic_id_and_outreach_priority_id", :unique => true

  create_table "outreach_priorities_users", :id => false, :force => true do |t|
    t.integer  "outreach_priority_id", :default => 0, :null => false
    t.integer  "user_id",              :default => 0, :null => false
    t.datetime "created_at"
  end

  add_index "outreach_priorities_users", ["outreach_priority_id", "user_id"], :name => "index_outreach_priority_id_and_user_id", :unique => true
  add_index "outreach_priorities_users", ["user_id", "outreach_priority_id"], :name => "index_user_id_and_outreach_priority_id", :unique => true

  create_table "outreach_priority_groups", :force => true do |t|
    t.integer  "outreach_priority_id"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "package_subscription_terms", :force => true do |t|
    t.datetime "created_at",                :null => false
    t.string   "time_period", :limit => 50, :null => false
    t.integer  "days"
  end

  create_table "package_tabs", :force => true do |t|
    t.integer  "tab_id",       :null => false
    t.datetime "created_at",   :null => false
    t.integer  "tab_sequence", :null => false
  end

  create_table "package_types", :force => true do |t|
    t.datetime "created_at",                :null => false
    t.string   "name",       :limit => 150, :null => false
  end

  create_table "packages", :force => true do |t|
    t.integer  "base_package_id"
    t.datetime "created_at",                                                                  :null => false
    t.integer  "organization_id",                                                             :null => false
    t.string   "name",                         :limit => 150,                                 :null => false
    t.string   "description",                  :limit => 4000
    t.integer  "package_subscription_term_id"
    t.datetime "subscription_start_date"
    t.datetime "subscription_end_date"
    t.decimal  "price",                                        :precision => 18, :scale => 2
    t.string   "dnn_template_name"
    t.integer  "package_type_id",                                                             :null => false
    t.boolean  "is_public",                                                                   :null => false
    t.boolean  "is_deployable",                                                               :null => false
  end

  add_index "packages", ["organization_id", "name"], :name => "UK_Packages_OrgAndName", :unique => true

  create_table "page_sections", :force => true do |t|
    t.integer  "organization_id", :null => false
    t.string   "page",            :null => false
    t.string   "section"
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "body"
    t.integer  "author_id"
  end

  add_index "page_sections", ["organization_id", "page", "section"], :name => "index_page_sections_on_organization_id_and_page_and_section"

  create_table "payments", :force => true do |t|
    t.integer  "merchant_account_id"
    t.integer  "transaction_status_id"
    t.integer  "fundraising_campaign_id"
    t.integer  "user_id"
    t.decimal  "amount",                                :precision => 9, :scale => 2, :default => 0.0
    t.string   "memo"
    t.string   "authorization_code"
    t.string   "response_message"
    t.string   "card_number",             :limit => 32
    t.integer  "organization_id"
    t.string   "card_holder_name"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "billing_state_province"
    t.string   "billing_postal_code"
    t.string   "billing_country"
    t.string   "billing_phone",           :limit => 20
    t.string   "card_type",               :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permission_types", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at",               :null => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "content_id"
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "permission_type_id", :null => false
    t.datetime "created_at",         :null => false
  end

  add_index "permissions", ["channel_id", "id"], :name => "IDX_Permissions1"
  add_index "permissions", ["content_id", "id"], :name => "IDX_Permissions2"
  add_index "permissions", ["role_id", "id"], :name => "IDX_Permissions4"
  add_index "permissions", ["user_id", "id"], :name => "IDX_Permissions3"

  create_table "players", :force => true do |t|
    t.datetime "created_at",                  :null => false
    t.string   "name",        :limit => 50,   :null => false
    t.string   "version",     :limit => 20
    t.string   "protocol",    :limit => 30
    t.string   "description", :limit => 4000
    t.string   "html_code",   :limit => 4000
  end

  create_table "prayer_pledges", :force => true do |t|
    t.string   "first_name",                :limit => 50
    t.string   "last_name",                 :limit => 50
    t.string   "email_address",             :limit => 512
    t.string   "state_province",            :limit => 50
    t.string   "country"
    t.string   "city"
    t.string   "phone_number"
    t.string   "phone_provider"
    t.boolean  "send_reminder_day_before"
    t.boolean  "send_interest_of_interest"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "i18n_locale"
    t.boolean  "should_inform",                            :default => true
  end

  create_table "related_content_types", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.datetime "created_at",                :null => false
  end

  create_table "related_contents", :force => true do |t|
    t.integer  "content_id", :null => false
    t.datetime "created_at", :null => false
  end

  create_table "related_organizations", :id => false, :force => true do |t|
    t.integer  "organization_id",         :null => false
    t.integer  "related_organization_id", :null => false
    t.datetime "created_at",              :null => false
  end

  create_table "religious_affiliations", :force => true do |t|
    t.string   "name",       :limit => 150, :null => false
    t.datetime "created_at",                :null => false
    t.integer  "parent_id"
    t.integer  "channel_id"
  end

  create_table "reported_abuses", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "abuse",           :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reported_abuses", ["entity_id", "entity_type", "abuse"], :name => "index_reported_abuses_on_entity_id_and_entity_type_and_abuse"

  create_table "role_memberships", :force => true do |t|
    t.integer  "user_id",                             :null => false
    t.integer  "role_id",                             :null => false
    t.datetime "created_at",                          :null => false
    t.boolean  "has_grant_option", :default => false, :null => false
    t.datetime "starts_at"
    t.datetime "ends_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :limit => 50,   :null => false
    t.datetime "created_at",                  :null => false
    t.integer  "user_id",                     :null => false
    t.string   "description", :limit => 1000
    t.integer  "scope_id"
    t.string   "scope_type"
  end

  add_index "roles", ["scope_id", "scope_type", "name"], :name => "index_roles_on_scope_id_and_scope_type_and_name"

  create_table "roles_granted_roles", :force => true do |t|
    t.integer  "role_id",         :null => false
    t.integer  "granted_Role_id", :null => false
    t.datetime "created_at",      :null => false
  end

  add_index "roles_granted_roles", ["granted_Role_id", "role_id"], :name => "IDX_FSNRolesGrantedRoles1", :unique => true

  create_table "rubrics", :force => true do |t|
    t.integer  "scope_id"
    t.string   "scope_type"
    t.string   "name",             :limit => 15
    t.string   "abbrev",           :limit => 1
    t.integer  "score"
    t.text     "criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "is_active",                      :default => true
    t.string   "color_background", :limit => 7
    t.string   "color_font",       :limit => 7
  end

  add_index "rubrics", ["scope_id", "scope_type"], :name => "index_rubrics_on_scope_id_and_scope"
  add_index "rubrics", ["scope_type", "scope_id"], :name => "index_rubrics_on_scope_and_scope_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "setting_values", :force => true do |t|
    t.integer  "setting_id"
    t.integer  "scope_id",                   :null => false
    t.string   "scope_type", :limit => 32
    t.string   "value",      :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "setting_values", ["scope_id", "scope_type", "setting_id"], :name => ":scope_id_and_scope_type_and_style_setting_id"

  create_table "settings", :force => true do |t|
    t.string  "name",                                              :null => false
    t.string  "setting_type",                :default => "String"
    t.string  "group_name"
    t.integer "position"
    t.string  "default_value"
    t.string  "type",          :limit => 64
  end

  create_table "shares", :force => true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "share_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "star_ratings", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type", :limit => 32
    t.integer  "votes",                                                   :default => 0
    t.decimal  "rating",                    :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string   "state",       :limit => 32,                   :null => false
    t.string   "country",     :limit => 3,                    :null => false
    t.datetime "created_at",                                  :null => false
    t.string   "name",        :limit => 50,                   :null => false
    t.boolean  "is_us_state",               :default => true, :null => false
  end

  create_table "statuses", :force => true do |t|
    t.datetime "created_at",               :null => false
    t.string   "name",       :limit => 50, :null => false
  end

  create_table "student_demographics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "grade_level_base"
    t.date     "grade_base_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_demographics", ["user_id"], :name => "index_student_demographics_on_user_id"

  create_table "student_subject_demographics", :force => true do |t|
    t.integer  "user_id"
    t.integer  "act_subject_id"
    t.integer  "latest_csap"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_subject_demographics", ["act_subject_id"], :name => "index_student_subject_demographics_on_act_subject_id"
  add_index "student_subject_demographics", ["user_id"], :name => "index_student_subject_demographics_on_user_id"

  create_table "subject_areas", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "act_subject_id"
    t.boolean  "is_core"
    t.boolean  "is_academic"
  end

  add_index "subject_areas", ["act_subject_id"], :name => "index_subject_areas_on_act_subject_id"

  create_table "survey_anons", :force => true do |t|
    t.integer  "tlt_survey_type_id"
    t.integer  "tlt_survey_audience_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_anons", ["tlt_survey_audience_id"], :name => "index_survey_anons_on_tlt_survey_audience_id"
  add_index "survey_anons", ["tlt_survey_type_id"], :name => "index_survey_anons_on_tlt_survey_type_id"

  create_table "survey_instructions", :force => true do |t|
    t.integer  "tlt_survey_audience_id"
    t.integer  "tlt_survey_type_id"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_notify"
    t.boolean  "is_anon"
    t.text     "subject_line"
    t.integer  "max_responses"
    t.integer  "default_days"
    t.boolean  "is_self_survey"
    t.text     "description"
  end

  add_index "survey_instructions", ["tlt_survey_audience_id"], :name => "index_survey_instructions_on_tlt_survey_audience_id"
  add_index "survey_instructions", ["tlt_survey_type_id"], :name => "index_survey_instructions_on_tlt_survey_type_id"

  create_table "survey_notifications", :force => true do |t|
    t.integer  "tlt_survey_type_id"
    t.integer  "tlt_survey_audience_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_notifications", ["tlt_survey_audience_id"], :name => "index_survey_notifications_on_tlt_survey_audience_id"
  add_index "survey_notifications", ["tlt_survey_type_id"], :name => "index_survey_notifications_on_tlt_survey_type_id"

  create_table "survey_schedule_takers", :force => true do |t|
    t.integer  "survey_schedule_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_schedule_takers", ["survey_schedule_id"], :name => "index_survey_schedule_takers_on_survey_schedule_id"
  add_index "survey_schedule_takers", ["user_id"], :name => "index_survey_schedule_takers_on_taker_id"

  create_table "survey_schedules", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type",            :limit => 32
    t.integer  "organization_id"
    t.integer  "tlt_survey_audience_id"
    t.integer  "tlt_survey_type_id"
    t.integer  "subject_area_id"
    t.date     "schedule_start"
    t.date     "schedule_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "is_active",                            :default => true
    t.integer  "max_responses",                        :default => 1000
    t.integer  "survey_instruction_id",                :default => 999
    t.boolean  "is_notify"
    t.boolean  "is_anon"
    t.integer  "recipients",                           :default => 1
  end

  add_index "survey_schedules", ["entity_type", "entity_id", "organization_id", "tlt_survey_audience_id", "tlt_survey_type_id"], :name => "entity_org_audience_type"
  add_index "survey_schedules", ["entity_type", "entity_id", "tlt_survey_audience_id", "tlt_survey_type_id"], :name => "entity_audience_type"
  add_index "survey_schedules", ["organization_id", "entity_type", "tlt_survey_audience_id", "tlt_survey_type_id"], :name => "org_entity_audience_type"
  add_index "survey_schedules", ["organization_id", "tlt_survey_audience_id", "tlt_survey_type_id"], :name => "org_audience_type"
  add_index "survey_schedules", ["subject_area_id"], :name => "index_survey_schedules_on_subject_area_id"
  add_index "survey_schedules", ["survey_instruction_id", "organization_id"], :name => "instruction_org"
  add_index "survey_schedules", ["user_id", "organization_id", "entity_type"], :name => "user_org_entity"
  add_index "survey_schedules", ["user_id", "tlt_survey_audience_id", "tlt_survey_type_id"], :name => "user_audience_type"

  create_table "tags", :force => true do |t|
    t.string   "name",       :limit => 150, :null => false
    t.datetime "created_at",                :null => false
  end

  add_index "tags", ["name"], :name => "UK_Tags_Tag", :unique => true

  create_table "talents", :force => true do |t|
    t.integer "user_id"
    t.string  "name"
  end

  create_table "tchr_metrics", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "for_teacher"
    t.boolean  "for_classroom"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev"
    t.boolean  "by_month"
  end

  create_table "tchr_option_metrics", :force => true do |t|
    t.integer  "tchr_option_id"
    t.integer  "tchr_metric_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tchr_options", :force => true do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "end_is_current_date"
  end

  create_table "time_allocations", :force => true do |t|
    t.integer  "organization_id"
    t.decimal  "weekday_std",     :precision => 2, :scale => 1, :default => 5.0
    t.decimal  "daysyear_std",    :precision => 4, :scale => 1, :default => 180.0
    t.decimal  "daysyear_er",     :precision => 4, :scale => 1, :default => 0.0
    t.decimal  "daysyear_ls",     :precision => 4, :scale => 1, :default => 0.0
    t.decimal  "fte_teacher",     :precision => 4, :scale => 1, :default => 0.0
    t.decimal  "fte_admin",       :precision => 4, :scale => 1, :default => 0.0
    t.integer  "total_students",                                :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "hrsday_std",      :precision => 4, :scale => 2, :default => 6.5
    t.decimal  "hrsday_er",       :precision => 4, :scale => 2, :default => 4.5
    t.decimal  "hrsday_ls",       :precision => 4, :scale => 2, :default => 4.5
  end

  add_index "time_allocations", ["organization_id"], :name => "index_time_allocations_on_organization_id"

  create_table "tl_activity_type_tasks", :force => true do |t|
    t.integer  "tl_activity_type_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "abbrev"
    t.boolean  "is_enabled"
    t.integer  "research"
    t.integer  "position"
  end

  add_index "tl_activity_type_tasks", ["tl_activity_type_id"], :name => "index_tl_activity_type_tasks_on_tl_activity_type_id"

  create_table "tl_activity_types", :force => true do |t|
    t.string   "activity"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "seq_num"
    t.string   "abbrev"
    t.integer  "app_method_id"
  end

  add_index "tl_activity_types", ["app_method_id"], :name => "index_tl_activity_types_on_app_method_id"
  add_index "tl_activity_types", ["seq_num"], :name => "index_tl_activity_types_on_seq_num"

  create_table "tl_strategy_descripts", :force => true do |t|
    t.integer  "tl_activity_type_task_id"
    t.text     "description"
    t.text     "research"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tl_strategy_descripts", ["tl_activity_type_task_id"], :name => "strategy"

  create_table "tl_strategy_descs", :force => true do |t|
    t.integer  "tl_activity_type_task_id"
    t.text     "description"
    t.text     "research"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tl_strategy_descs", ["tl_activity_type_task_id"], :name => "ctl-strategy"

  create_table "tl_student_involvements", :force => true do |t|
    t.string   "label",      :limit => 10
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "measure",    :limit => 10
  end

  create_table "tlt_cycles", :force => true do |t|
    t.string   "cycle"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stage"
  end

  create_table "tlt_dashboards", :force => true do |t|
    t.integer  "tlt_session_id"
    t.integer  "user_id"
    t.integer  "tracker_id"
    t.integer  "classroom_id"
    t.integer  "topic_id"
    t.integer  "organization_id"
    t.integer  "tl_activity_type_id"
    t.integer  "tl_activity_type_task_id"
    t.integer  "subject_area_id"
    t.integer  "duration_secs"
    t.integer  "duration_pct"
    t.integer  "segments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "involve_total"
    t.integer  "involve_count"
    t.integer  "impact_total"
    t.integer  "impact_count"
  end

  add_index "tlt_dashboards", ["classroom_id"], :name => "index_tlt_dashboards_on_classroom_id"
  add_index "tlt_dashboards", ["organization_id"], :name => "index_tlt_dashboards_on_organization_id"
  add_index "tlt_dashboards", ["subject_area_id"], :name => "index_tlt_dashboards_on_subject_area_id"
  add_index "tlt_dashboards", ["tl_activity_type_id"], :name => "index_tlt_dashboards_on_tl_activity_type_id"
  add_index "tlt_dashboards", ["tl_activity_type_task_id"], :name => "index_tlt_dashboards_on_tl_activity_type_task_id"
  add_index "tlt_dashboards", ["tlt_session_id"], :name => "index_tlt_dashboards_on_tlt_session_id"
  add_index "tlt_dashboards", ["topic_id"], :name => "index_tlt_dashboards_on_topic_id"
  add_index "tlt_dashboards", ["tracker_id"], :name => "index_tlt_dashboards_on_tracker_id"
  add_index "tlt_dashboards", ["user_id"], :name => "index_tlt_dashboards_on_user_id"

  create_table "tlt_diagnostic_lessons", :force => true do |t|
    t.integer  "tl_activity_type_id"
    t.text     "strategies"
    t.text     "how_effective"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tlt_diagnostic_id"
  end

  add_index "tlt_diagnostic_lessons", ["tl_activity_type_id"], :name => "index_tlt_diagnostic_lessons_on_tlt_activity_type_id"
  add_index "tlt_diagnostic_lessons", ["tlt_diagnostic_id"], :name => "index_tlt_diagnostic_lessons_on_tlt_diagnostic_id"

  create_table "tlt_diagnostics", :force => true do |t|
    t.integer  "user_id"
    t.text     "conclusions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "subject_area_id"
    t.integer  "organization_id"
  end

  add_index "tlt_diagnostics", ["organization_id"], :name => "index_tlt_diagnostics_on_organization_id"
  add_index "tlt_diagnostics", ["subject_area_id"], :name => "index_tlt_diagnostics_on_subject_area_id"

  create_table "tlt_session_app_methods", :force => true do |t|
    t.integer  "tlt_session_id"
    t.integer  "app_method_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tlt_session_app_methods", ["app_method_id", "tlt_session_id"], :name => "app_method_session"
  add_index "tlt_session_app_methods", ["tlt_session_id"], :name => "index_tlt_session_app_methods_on_tlt_session_id"

  create_table "tlt_session_logs", :force => true do |t|
    t.integer  "tlt_session_id"
    t.integer  "tl_activity_type_task_id"
    t.datetime "start_time"
    t.integer  "duration"
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active"
    t.text     "involve"
    t.integer  "tl_student_involvement_id"
    t.integer  "impact_score"
    t.integer  "involve_score"
    t.string   "impact"
  end

  add_index "tlt_session_logs", ["impact_score"], :name => "index_tlt_session_logs_on_impact_score"
  add_index "tlt_session_logs", ["involve_score"], :name => "index_tlt_session_logs_on_involve_score"
  add_index "tlt_session_logs", ["tl_activity_type_task_id"], :name => "index_tlt_session_logs_on_tl_activity_type_task_id"
  add_index "tlt_session_logs", ["tl_student_involvement_id"], :name => "index_tlt_session_logs_on_tl_student_involvement_id"
  add_index "tlt_session_logs", ["tlt_session_id", "tl_activity_type_task_id"], :name => "session_log_task"
  add_index "tlt_session_logs", ["tlt_session_id"], :name => "index_tlt_session_logs_on_tlt_session_id"

  create_table "tlt_session_videos", :force => true do |t|
    t.integer  "tlt_session_id"
    t.binary   "embed_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tlt_session_videos", ["tlt_session_id"], :name => "index_tlt_session_videos_on_tlt_session_id"

  create_table "tlt_sessions", :force => true do |t|
    t.integer  "classroom_id"
    t.integer  "user_id"
    t.integer  "tracker_id"
    t.string   "lesson"
    t.integer  "students"
    t.text     "observations"
    t.text     "learning"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id"
    t.integer  "organization_id"
    t.integer  "subject_area_id"
    t.boolean  "is_final"
    t.date     "session_date"
    t.boolean  "is_manual"
    t.date     "observer_done_date"
    t.date     "finalize_date"
    t.text     "teacher_remark"
    t.boolean  "logs_are_closed"
    t.boolean  "is_observer_done"
    t.boolean  "is_teacher_done"
    t.date     "teacher_done_date"
    t.text     "next_step"
    t.date     "student_survey_date"
    t.integer  "tlt_cycle_id"
    t.integer  "duration"
    t.integer  "classroom_period_id"
    t.integer  "session_length",      :default => 0
    t.text     "class_period_name"
    t.text     "classroom_name"
    t.boolean  "is_training"
    t.integer  "content_id"
    t.integer  "itl_belt_rank_id"
    t.integer  "itl_template_id"
    t.integer  "old_template_id"
  end

  add_index "tlt_sessions", ["classroom_id"], :name => "index_tlt_sessions_on_classroom_id"
  add_index "tlt_sessions", ["classroom_period_id"], :name => "index_tlt_sessions_on_classroom_period_id"
  add_index "tlt_sessions", ["content_id"], :name => "index_tlt_sessions_on_content_id"
  add_index "tlt_sessions", ["itl_belt_rank_id"], :name => "index_tlt_sessions_on_itl_belt_rank_id"
  add_index "tlt_sessions", ["itl_template_id"], :name => "index_tlt_sessions_on_itl_template_id"
  add_index "tlt_sessions", ["organization_id", "session_date"], :name => "org_session_date"
  add_index "tlt_sessions", ["organization_id", "subject_area_id", "session_date"], :name => "org_subject_date"
  add_index "tlt_sessions", ["organization_id", "tracker_id", "session_date"], :name => "org_observer_date"
  add_index "tlt_sessions", ["organization_id", "user_id", "session_date"], :name => "org_teacher_date"
  add_index "tlt_sessions", ["subject_area_id"], :name => "index_tlt_sessions_on_subject_area_id"
  add_index "tlt_sessions", ["tlt_cycle_id"], :name => "index_tlt_sessions_on_tlt_cycle_id"
  add_index "tlt_sessions", ["topic_id"], :name => "index_tlt_sessions_on_topic_id"
  add_index "tlt_sessions", ["tracker_id"], :name => "index_tlt_sessions_on_tracker_id"
  add_index "tlt_sessions", ["user_id", "session_date"], :name => "teacher_date"
  add_index "tlt_sessions", ["user_id", "subject_area_id", "session_date"], :name => "teacher_subject_date"

  create_table "tlt_survey_audiences", :force => true do |t|
    t.integer  "coop_app_id"
    t.string   "audience",    :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tlt_survey_audiences", ["coop_app_id"], :name => "index_tlt_survey_audiences_on_coop_app_id"

  create_table "tlt_survey_questions", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.integer  "tlt_survey_range_type_id"
    t.boolean  "is_active",                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tlt_survey_audience_id"
    t.integer  "coop_app_id"
    t.integer  "tlt_survey_type_id"
    t.string   "question"
    t.integer  "position"
  end

  add_index "tlt_survey_questions", ["organization_id", "coop_app_id"], :name => "org_app"
  add_index "tlt_survey_questions", ["organization_id", "tlt_survey_audience_id", "tlt_survey_type_id"], :name => "org_audience_type"
  add_index "tlt_survey_questions", ["tlt_survey_range_type_id"], :name => "index_tlt_survey_questions_on_tlt_range_type_id"
  add_index "tlt_survey_questions", ["user_id"], :name => "index_tlt_survey_questions_on_user_id"

  create_table "tlt_survey_range_types", :force => true do |t|
    t.string   "label"
    t.string   "low_end"
    t.string   "high_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tlt_survey_responses", :force => true do |t|
    t.integer  "tlt_session_id"
    t.integer  "user_id"
    t.integer  "tlt_survey_question_id"
    t.integer  "score"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tlt_survey_audience_id"
    t.integer  "tlt_survey_type_id"
    t.integer  "tlt_diagnostic_id"
    t.integer  "subject_area_id"
    t.integer  "organization_id"
    t.integer  "user_dle_plan_id"
    t.integer  "survey_schedule_id"
  end

  add_index "tlt_survey_responses", ["organization_id"], :name => "index_tlt_survey_responses_on_organization_id"
  add_index "tlt_survey_responses", ["subject_area_id"], :name => "index_tlt_survey_responses_on_subject_area_id"
  add_index "tlt_survey_responses", ["survey_schedule_id", "tlt_survey_question_id"], :name => "survey_question"
  add_index "tlt_survey_responses", ["survey_schedule_id", "user_id"], :name => "survey_user"
  add_index "tlt_survey_responses", ["tlt_diagnostic_id"], :name => "index_tlt_survey_responses_on_tlt_diagnostic_id"
  add_index "tlt_survey_responses", ["tlt_session_id", "tlt_survey_audience_id"], :name => "observation_audience"
  add_index "tlt_survey_responses", ["tlt_survey_audience_id"], :name => "index_tlt_survey_responses_on_tlt_survey_audience_id"
  add_index "tlt_survey_responses", ["tlt_survey_question_id", "score"], :name => "question_score"
  add_index "tlt_survey_responses", ["tlt_survey_type_id"], :name => "index_tlt_survey_responses_on_tlt_survey_type_id"
  add_index "tlt_survey_responses", ["user_dle_plan_id"], :name => "index_tlt_survey_responses_on_user_dle_plan_id"
  add_index "tlt_survey_responses", ["user_id", "organization_id"], :name => "user_organization"

  create_table "tlt_survey_types", :force => true do |t|
    t.string   "abbrev",      :limit => 5
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coop_app_id"
    t.string   "name",        :limit => 20
    t.integer  "sequence"
  end

  create_table "topic_contents", :force => true do |t|
    t.integer  "topic_id",                        :null => false
    t.integer  "content_id",                      :null => false
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "display_position", :default => 0
    t.integer  "folder_id"
  end

  add_index "topic_contents", ["content_id"], :name => "index_topic_contents_on_content_id"
  add_index "topic_contents", ["folder_id", "content_id"], :name => "folder_for_content"
  add_index "topic_contents", ["folder_id", "topic_id"], :name => "folder_for_topic"
  add_index "topic_contents", ["folder_id"], :name => "index_topic_contents_on_folder_id"
  add_index "topic_contents", ["topic_id", "content_id"], :name => "topic_for_content"
  add_index "topic_contents", ["topic_id", "folder_id"], :name => "topic_for_folder"
  add_index "topic_contents", ["topic_id"], :name => "index_topic_contents_on_topic_id"

  create_table "topics", :force => true do |t|
    t.integer  "user_id",                                                  :null => false
    t.string   "title"
    t.string   "description",           :limit => 8000
    t.boolean  "searchable",                            :default => true,  :null => false
    t.datetime "publish_starts_at"
    t.datetime "publish_ends_at"
    t.datetime "last_posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "discussion_question",   :limit => 1000
    t.integer  "featured_content"
    t.integer  "classroom_id"
    t.text     "instructional_remarks"
    t.text     "assignments"
    t.date     "estimated_start_date"
    t.date     "estimated_end_date"
    t.boolean  "is_open",                               :default => true
    t.boolean  "should_notify",                         :default => false
    t.integer  "act_score_range_id"
  end

  add_index "topics", ["act_score_range_id"], :name => "index_topics_on_act_score_range_id"
  add_index "topics", ["classroom_id"], :name => "index_topics_on_classroom_id"

  create_table "total_shares", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "shares",                    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "entity_type", :limit => 32
  end

  add_index "total_shares", ["entity_type", "entity_id"], :name => "index_total_shares_on_entity_type_and_entity_id"

  create_table "total_views", :force => true do |t|
    t.integer  "entity_id"
    t.string   "entity_type", :limit => 32
    t.integer  "views",                     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "total_views", ["entity_type", "entity_id"], :name => "index_total_views_on_entity_type_and_entity_id"

  create_table "transaction_statuses", :force => true do |t|
    t.string   "name",        :limit => 32
    t.string   "color",       :limit => 8
    t.string   "description", :limit => 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trusted_sources", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "source_id"
    t.string   "type",            :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trusted_sources", ["organization_id", "source_id", "type"], :name => "index_trusted_sources_on_organization_id_and_source_id_and_type", :unique => true

  create_table "user_dle_plan_coachings", :force => true do |t|
    t.integer  "user_dle_plan_id"
    t.integer  "user_id"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_dle_plan_coachings", ["user_dle_plan_id"], :name => "index_user_dle_plan_coachings_on_user_dle_plan_id"

  create_table "user_dle_plan_metrics", :force => true do |t|
    t.integer  "user_dle_plan_id"
    t.integer  "dle_metric_id"
    t.decimal  "target",           :precision => 7, :scale => 2, :default => 0.0
    t.decimal  "actual",           :precision => 7, :scale => 2, :default => 0.0
    t.string   "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_dle_plans", :force => true do |t|
    t.integer  "user_id"
    t.integer  "dle_cycle_id"
    t.date     "date_finalized"
    t.text     "output_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attach_content_type"
    t.string   "attach_file_name"
    t.integer  "attach_file_size"
    t.date     "cycle_start_date"
    t.boolean  "is_current",          :default => true
    t.string   "attach_title"
    t.date     "attach_date"
    t.integer  "plan"
  end

  add_index "user_dle_plans", ["cycle_start_date"], :name => "index_user_dle_plans_on_cycle_start_date"
  add_index "user_dle_plans", ["date_finalized"], :name => "index_user_dle_plans_on_date_finalized"
  add_index "user_dle_plans", ["user_id", "dle_cycle_id"], :name => "index_user_dle_plans_on_user_id_and_dle_cycle_id"
  add_index "user_dle_plans", ["user_id", "plan"], :name => "index_user_dle_plans_on_user_id_and_plan"

  create_table "user_itl_belt_ranks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "itl_belt_rank_id"
    t.string   "grantor_name",     :limit => 40, :default => ""
    t.text     "justification"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_itl_belt_ranks", ["itl_belt_rank_id"], :name => "index_user_itl_belt_ranks_on_itl_belt_rank_id"
  add_index "user_itl_belt_ranks", ["user_id"], :name => "index_user_itl_belt_ranks_on_user_id"

  create_table "users", :force => true do |t|
    t.integer  "religious_affiliation_id"
    t.datetime "created_at",                                                    :null => false
    t.integer  "status_id"
    t.string   "first_name",                  :limit => 50
    t.string   "last_name",                   :limit => 50
    t.string   "phone",                       :limit => 20
    t.string   "alt_phone",                   :limit => 20
    t.string   "other_denomination",          :limit => 50
    t.string   "postal_code",                 :limit => 20
    t.datetime "date_of_birth"
    t.boolean  "age_verified",                                                  :null => false
    t.boolean  "read_tos",                                                      :null => false
    t.string   "display_name",                :limit => 128
    t.string   "verification_code",           :limit => 16
    t.datetime "verified_at"
    t.string   "password",                                                      :null => false
    t.string   "salt",                        :limit => 256
    t.string   "email_address",               :limit => 512
    t.string   "crypted_password"
    t.datetime "updated_at"
    t.string   "country"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "state_province"
    t.string   "personal_url"
    t.string   "city"
    t.text     "credentials"
    t.text     "philosophy"
    t.boolean  "display_emai_and_phone",                     :default => true
    t.string   "website_referred_as"
    t.string   "Phone_for_Texting"
    t.string   "Provider_of_Texting_Service"
    t.integer  "home_org_id"
    t.string   "preferred_email"
    t.string   "alt_login",                                  :default => ""
    t.string   "std_view"
    t.integer  "act_master_id"
    t.boolean  "calibrated_only",                            :default => false
    t.boolean  "is_student"
    t.integer  "organization_id"
    t.boolean  "is_suspended"
    t.date     "last_logon"
  end

  add_index "users", ["home_org_id"], :name => "index_users_on_home_org_id"
  add_index "users", ["is_student"], :name => "index_users_on_is_student"
  add_index "users", ["organization_id"], :name => "index_users_on_organization_id"

  create_table "zip_codes", :force => true do |t|
    t.string   "zip_code",   :limit => 10,                   :null => false
    t.datetime "created_at",                                 :null => false
    t.string   "city",       :limit => 50,                   :null => false
    t.string   "state",      :limit => 32,                   :null => false
    t.string   "country",    :limit => 3,  :default => "US", :null => false
  end

end
