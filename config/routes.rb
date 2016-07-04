EscentPartners::Application.routes.draw do |map|

  # You can have the root of your site routed with "root"
 # root to: 'fsn#index'
  get '/root' => 'fsn#index'
  # <%= link_to 'Edit Profile', user_edit_path %>
  #     <a href="/profile/edit">Edit Profile</a>

  # <%= link_to 'Edit Profile', profile_edit_url %>
  #     <a href="http://localhost:3000/profile/edit">Edit Profile</a>
  #   *** USE THIS IN ANY MAILERS ***

  #  CORE Main Page
  get '/ep' => 'fsn#index'
  get '/ep/blog/view' => 'fsn#select_blog'
  get '/ep/tos' => 'fsn#terms'

  # CORE User
  get '/user/edit' => 'users#edit_profile'
  post '/user/edit' => 'users#edit_profile'
  get '/user/view' => 'users#member_public_profile'
  post '/user/edit_home' => 'users#change_home_org'
  post '/user/edit_password' => 'users#change_password'
  get '/user/assign_std' => 'users#assign_standard_view'
  get '/user/toggle_org' => 'users#toggle_favorite_organization'
  get '/user/toggle_offering' => 'users#toggle_favorite_classroom'
  get '/user/remove_colleague' => 'users#remove_this_colleague'
  get '/user/tag_colleague' => 'users#add_this_colleague'
  get '/user/remove_resource' => 'users#remove_this_favorite_resource'
  get '/user/tag_resource' => 'users#add_this_favorite_resource'
  get '/user/signout' => 'users#logout'
  post '/user/signin' => 'users#login'
  get '/user/register' => 'users#register'  # user_register
  post '/user/register' => 'users#register'  # user_register
  get '/user/forgot_password' => 'users#forgot_password'
  post '/user/forgot_password' => 'users#forgot_password'
  get '/user/bio/edit' => 'users#edit_user_bio'
  post '/user/bio/edit' => 'users#edit_user_bio'

  # CORE Resource (Content)
  get '/resource/view' => 'site/site#static_resource'
  get '/resource/new' => 'site/contents#submit_resource'
  post '/resource/new' => 'site/contents#submit_resource'
  get '/resource/show' => 'site/contents#index'
  get '/resource/edit' => 'site/contents#edit_resource'
  post '/resource/edit' => 'site/contents#edit_resource'
  get '/resource/assess/edit' => 'site/contents#edit_assess'
  get '/resource/subjects' => 'site/contents#select_subject_areas'
  get '/resource/types' => 'site/contents#select_resource_types'
  get '/resource/share' => 'site/discussions#share_content'
  post '/resource/share' => 'site/discussions#share_content'
  get '/resource/group/show' => 'site/contents#show_group_content'
  get '/resource/group/select' => 'site/contents#select_content_group'
  put '/resource/destroy' => 'site/contents#destroy_selected'

  # CORE Organization
  get '/organization/view' => 'site/site#static_organization', :requirements => {:organization_id => /[a-f\d]{16}/}
  get '/organization/view/app' => 'site/site#summarize_org_app'
  get '/organization/view/offering' => 'site/site#summarize_org_subject_offerings'
  get '/organization/view/resources' => 'site/site#summarize_org_resources'

  # CORE Search
  get '/search' => 'site/site#search'
  post '/search' => 'site/site#search'
  get '/site/content/search' => 'site/site#search'
  get '/search/autocomplete' => 'site/site#keywords_autocomplete'

  # CORE Admin
  get '/admin' => 'admin/application#index'
  post '/admin' => 'admin/application#index'
  get '/admin/notify' => 'admin/our_organization#toggle_notification'
  post '/admin/org/profile' => 'admin/our_organization#update_profile'
  post '/admin/org/logo' => 'admin/our_organization#update_logo'
  get '/admin/org/colors' => 'admin/our_organization#change_style_setting'
  get '/admin/org/apps' => 'admin/our_organization#coop_app_enable_disable'
  get '/admin/family/authorizations' => 'admin/our_family#new_user_authorization'
  get '/admin/family/show' => 'admin/our_family#view_auth_members'
  get '/admin/family/user_authorizations' => 'admin/our_family#authorize_user'
  get '/admin/family/authorize' => 'admin/our_family#toggle_authorization'
  get '/admin/family/owner_authorize' => 'admin/our_family#toggle_app_authorization'
  get '/admin/provider/app/name' => 'admin/our_organization#edit_app_alt_name'
  get '/admin/provider/app/enable' => 'admin/our_organization#provider_app_enable'

  # CORE Maintenance
  get '/core/maint/status' => 'apps/owner_maintenance#core_maintain_statuses'
  get '/core/maint/org/status' => 'apps/owner_maintenance#core_org_status'
  get '/core/maint/status/assign' => 'apps/owner_maintenance#core_assign_status'
  get '/core/maint/children' => 'apps/owner_maintenance#core_maintain_child_parent'
  get '/core/maint/org/children' => 'apps/owner_maintenance#core_org_child_parent'
  get '/core/maint/parent/create' => 'apps/owner_maintenance#core_make_parent'
  get '/core/maint/parent/assign' => 'apps/owner_maintenance#core_assign_parent'

  # CORE Master
  get '/master/index' => 'master/application#index'
  post '/master/signin' => 'master/application#login'
  get '/master/users/show' => 'master/users#index'
  get '/master/users/delete' => 'master/users#delete'
  get '/master/users/suspend' => 'master/users#toggle_suspend'
  get '/master/users/super' => 'master/users#toggle_su'
  get '/master/organizations/show' => 'master/organizations#index'
  get '/master/organizations/delete' => 'master/organizations#delete'
  get '/master/organizations/app_owners' => 'master/organizations#ownership'
  get '/master/organizations/app/owner' => 'master/organizations#change_app_master'
  get '/master/organizations/discussion/owner' => 'master/organizations#change_app_discussion_owner'
  get '/master/organizations/app/provider' => 'master/organizations#toggle_co_owner'
  get '/master/organizations/app_usage' => 'master/organizations#app_useability'
  get '/master/organizations/app/enable' => 'master/organizations#change_app_useability'
  get '/master/organizations/new' => 'master/organizations#new'
  post '/master/organizations/new' => 'master/organizations#new'
  get '/master/organizations/new/success' => 'master/organizations#registration_successful'
  get '/master/apps/new' => 'master/coop_apps#edit_app'
  get '/master/apps/view' => 'master/coop_apps#index'
  get '/master/apps/edit' => 'master/coop_apps#edit_app'
  post '/master/apps/edit' => 'master/coop_apps#edit_app'
  get '/master/apps/settings/edit' => 'master/coop_apps#edit_app_settings'
  post '/master/apps/settings/edit' => 'master/coop_apps#edit_app_settings'
  # get '/master/core/maintenance_1' => 'master/coop_apps#maint_action'
  # get '/master/ctl/maintenance_1' => 'master/coop_apps#maint_action'
  get '/master/ctl/video/show' => 'master/coop_apps#show_user_video_session'
  post '/master/ctl/strategies/edit' => 'master/coop_apps#ctl_strategy_update'
  get '/master/ctl/strategies' => 'master/coop_apps#ctl_strategies_maintain'
  get '/master/ctl/session' => 'master/coop_apps#ctl_strategies_maintain'
  # get '/master/ifa/maintenance_1' => 'master/coop_apps#maint_action'
  # get '/master/blog/maintenance_1' => 'master/coop_apps#maint_action'
  # get '/master/offering/maintenance_1' => 'master/coop_apps#maint_action'
  # get '/master/pd/maintenance_1' => 'master/coop_apps#maint_action'
  # get '/master/ita/maintenance_1' => 'master/coop_apps#maint_action'
  # get '/master/elt/maintenance_1' => 'master/coop_apps#maint_action'

  # CORE Discussions
  get '/discussion/resource/comment/delete' => 'site/discussions#delete_resource_comment'
  post '/discussion/resource/comment/new' => 'site/discussions#add_comment_for_resource'
  get '/discussion/share' => 'site/discussions#share_discussion'
  post '/discussion/share' => 'site/discussions#share_discussion'
  get '/discussion/reply' => 'site/discussions#add_reply'
  post '/discussion/reply' => 'site/discussions#add_reply'
  get '/discussion/reply/delete' => 'site/discussions#delete_reply'
  post '/discussion/comment/new' => 'site/discussions#add_comment'
  get '/discussion/report/abuse' => 'site/discussions#report_abuse'
  post '/discussion/report/abuse' => 'site/discussions#report_abuse'

  # Main Application Route Paths
  get CoopApp.classroom.route_url => CoopApp.classroom.route_action
  get CoopApp.ifa.route_url => CoopApp.ifa.route_action
  get CoopApp.ctl.route_url => CoopApp.ctl.route_action
  get CoopApp.pd.route_url => CoopApp.pd.route_action
  get CoopApp.ita.route_url => CoopApp.ita.route_action
  get CoopApp.stat.route_url => CoopApp.stat.route_action
  get CoopApp.cm.route_url => CoopApp.cm.route_action
  get CoopApp.elt.route_url => CoopApp.elt.route_action
  get CoopApp.blog.route_url => CoopApp.blog.route_action

  # APPS Shared
  get '/app/owner/maintenance' => 'apps/owner_maintenance#index'
  get '/survey/take' => 'apps/shared#take_survey'
  post '/survey/take' => 'apps/shared#take_survey'
  post '/survey/submit' => 'apps/shared#submit_survey'
  get '/my_survey/view' => 'apps/shared#my_surveys'
  get '/my_survey/taken' => 'apps/shared#my_taken_surveys'
  get '/my_survey/broadcast' => 'apps/shared#my_broadcast_surveys'
  get '/my_survey/self' => 'apps/shared#my_self_surveys'
  get '/surveys/show' => 'apps/shared#list_surveys'
  get '/surveys/others/show' => 'apps/shared#list_surveys_others'
  get '/surveys/copy' => 'apps/shared#copy_survey'
  get '/survey/activate' => 'apps/shared#toggle_survey'
  get '/survey/app/activate' => 'apps/shared#app_survey_activate'
  get '/survey/app/deactivate' => 'apps/shared#app_survey_deactivate'
  get '/survey/position' => 'apps/shared#position_survey'
  get '/survey/question/new' => 'apps/shared#create_survey_question'
  get '/survey/question/add' => 'apps/shared#add_survey_question'
  get '/survey/question/destroy' => 'apps/shared#destroy_survey_question'
  get '/survey/question/analyze' => 'apps/shared#analyze_question'
  get '/survey/question/history' => 'apps/shared#question_history'
  get '/survey/broadcast' => 'apps/shared#broadcast_app_survey'
  get '/survey/results/show' => 'apps/shared#show_results'
  get '/surveys/results/show' => 'apps/shared#show_aggregated_results'

  get '/app/folder/edit' => 'apps/shared#edit_folder'
  get '/app/folder/new' => 'apps/shared#create_folder'
  get '/app/folder/destroy' => 'apps/shared#destroy_folder'
  get '/app/rubric/add' => 'apps/shared#maintain_rubric'
  post '/app/rubric/add' => 'apps/shared#maintain_rubric'

  get '/app/resource/assign' => 'apps/shared#add_remove_resource'

  # APP Offering  (Classroom)
  # site/site
  get '/offering/view' => 'site/site#static_classroom'
  get '/offering/homework' => 'site/site#submit_homework'
  put '/offering/homework' => 'site/site#submit_homework'
  get '/offering/lu/resources/featured' => 'site/site#featured_content'
  get '/offering/lu/resources/related' => 'site/site#related_content'
  get '/offering/lu/resources/sequence' => 'apps/classroom#offering_resource_sequence'
  # apps
  get '/offering/content/show_xxxx' => 'apps/classroom#show_content'   #  should no longer be needed
  get '/offering/setup' => 'apps/classroom#setup_classroom'
  get '/offering/lu/edit' => 'apps/classroom#setup_classroom_lu'
  get '/offering/toggle_favorite' => 'apps/classroom#toggle_favorite_classroom'
  get '/offering/unjoin' => 'apps/classroom#self_unregister_student'
  get '/offering/register' => 'apps/classroom#register_classroom'
  get '/offering/lu/resources/show' => 'apps/classroom#show_lu_resources'   # offering_lu_resources_show
  get '/offering/admin/assign_subject' => 'apps/classroom#identify_parent_subject'
  get '/offering/admin/add' => 'apps/classroom#add_classroom'
  get '/offering/admin/subjects' => 'apps/classroom#subject_offerings'
  get '/offering/admin/setup' => 'apps/classroom#setup_classroom'
  get '/offering/admin/destroy' => 'apps/classroom#destroy_classroom'
  get '/offering/admin/activate' => 'apps/classroom#toggle_active'
  get '/offering/admin/name/update' => 'apps/classroom#change_classroom_name'
  get '/offering/admin/subject/update' => 'apps/classroom#change_classroom_subject'
  get '/offering/admin/parent/subject' => 'apps/classroom#change_parent_subject'
  get '/offering/admin/periods' => 'apps/classroom#offering_periods'
  get '/offering/admin/period/add' => 'apps/classroom#add_period'
  get '/offering/admin/period/edit' => 'apps/classroom#edit_period'
  get '/offering/admin/period/teachers' => 'apps/classroom#manage_period_teachers'
  get '/offering/admin/period/destroy' => 'apps/classroom#destroy_period'
  get '/offering/admin/lus' => 'apps/classroom#offering_lus'
  get '/offering/admin/lu/add' => 'apps/classroom#add_lu'
  get '/offering/admin/lu/edit' => 'apps/classroom#setup_classroom_lu'
  post '/offering/admin/lu/edit' => 'apps/classroom#setup_classroom_lu'
  get '/offering/admin/lu/destroy' => 'apps/classroom#destroy_lu'
  get '/offering/admin/lu/options' => 'apps/classroom#toggle_lu_options'
  get '/offering/admin/lu/folder' => 'apps/shared#assign_lu_folder'
  get '/offering/admin/lu/folder/position' => 'apps/shared#assign_lu_folder_position'
  get '/offering/admin/resources' => 'apps/classroom#offering_resources'
  get '/offering/admin/resource/assign' => 'apps/classroom#add_remove_resource'
  get '/offering/admin/resource/feature' => 'apps/classroom#toggle_lu_featured_resource'
  get '/offering/admin/folders' => 'apps/classroom#offering_folders'
  get '/offering/admin/folder/setup' => 'apps/classroom#offering_folder_setup'
  get '/offering/admin/resource/folder' => 'apps/classroom#lu_resource_folder'
  get '/offering/admin/resource/copy' => 'apps/classroom#copy_lu_resources'
  get '/offering/admin/resource/pool' => 'apps/classroom#resource_pool'
  get '/offering/admin/referrals' => 'apps/classroom#offering_referrals'
  get '/offering/admin/referral/assign' => 'apps/classroom#add_remove_referral'
  get '/offering/admin/students' => 'apps/classroom#offering_students'
  get '/offering/admin/students/period' => 'apps/classroom#manage_period_students'
  get '/offering/admin/students/remove/all' => 'apps/classroom#remove_all_students'
  get '/offering/admin/student/assign' => 'apps/classroom#add_remove_student'
  get '/offering/admin/assessments' => 'apps/assessment#assign_classroom_assessment'
  get '/offering/admin/assessment/view' => 'apps/assessment#assign_classroom_assessment_view'
  get '/offering/admin/assessment/pool/update' => 'apps/assessment#update_classroom_assessment_pool'
  get '/offering/admin/surveys' => 'apps/classroom#offering_surveys'
  get '/offering/admin/survey/on' => 'apps/classroom#period_survey_activate'
  get '/offering/admin/survey/off' => 'apps/classroom#period_survey_deactivate'
  get '/offering/admin/homeworks' => 'apps/classroom#offering_homeworks'
  get '/offering/admin/option/activate' => 'apps/classroom#offering_options'
  get '/offering/admin/homework/delete' => 'apps/classroom#delete_homework'
  get '/offering/admin/teacher' => 'apps/classroom#manage_teacher'
  get '/offering/admin/teacher/subject' => 'apps/classroom#assign_for_subject'
  get '/offering/admin/teacher/period/assign' => 'apps/classroom#assign_period_teacher_1'
  get '/offering/admin/student/teacher/select' => 'apps/classroom#select_teacher'

  # APP Blogs
  get '/blog/view' => 'apps/app_blog#show_app_blog'
  get '/blog/show' => 'site/blogs#show'
  post '/blog/share' => 'site/blogs#share_blog'
  get '/blog/email' => 'apps/app_blog#share_email'
  get '/blog/comment/add' => 'apps/app_blog#new_add_comment'
  get '/blog/comment/remove' => 'apps/app_blog#delete_comment'
  get '/blog/admin/show' => 'apps/blogs#list_blogs'
  get '/blog/admin/add' => 'apps/blogs#create_blog'
  get '/blog/admin/edit' => 'apps/blogs#edit_blog'
  post '/blog/admin/edit' => 'apps/blogs#edit_blog'
  get '/blog/admin/destroy' => 'apps/blogs#destroy_blog'
  get '/blog/admin/activate' => 'apps/blogs#toggle_blog_activate'
  get '/blog/admin/feature' => 'apps/blogs#toggle_blog_feature'
  get '/blog/admin/commentable' => 'apps/blogs#toggle_blog_commentable'
  get '/blog/admin/reset' => 'apps/blogs#reset_views'
  get '/blog/admin/post/edit' => 'apps/blogs#edit_post'
  post '/blog/admin/post/edit' => 'apps/blogs#edit_post'
  get '/blog/admin/post/add' => 'apps/blogs#create_post'
  post '/blog/admin/post/add' => 'apps/blogs#create_post'
  get '/blog/admin/post/activate' => 'apps/blogs#toggle_blog_post_activate'
  get '/blog/admin/post/feature' => 'apps/blogs#toggle_blog_post_feature'
  get '/blog/admin/post/destroy' => 'apps/blogs#delete_blog_post'
  post '/blog/admin/post/image/add' => 'apps/blogs#add_post_picture'
  post '/blog/admin/post/image/remove' => 'apps/blogs#remove_post_flash'
  get '/blog/admin/post/image/show' => 'apps/blogs#show_blog_post_flash'
  get '/blog/admin/post/related' => 'apps/blogs#assign_related_post'
  post '/blog/admin/blog/image/add' => 'apps/blogs#add_blog_flash'
  post '/blog/admin/blog/image/remove' => 'apps/blogs#remove_blog_flash'
  get '/blog/admin/blog/image/show' => 'apps/blogs#show_blog_flash'
  get '/blog/admin/panel/assign' => 'apps/blogs#add_remove_blogger'
  get '/blog/admin/panel/activity' => 'apps/blogs#panelist_activity'
  get '/blog/admin/panelist/show' => 'apps/blogs#panelist_info'

  # APPS IFA
  get '/ifa/assessment/view' => 'apps/assessment#static_assessment'
  get '/ifa/teacher/review' => 'apps/assessment#teacher_review'
  get '/ifa/assessment/take' => 'apps/assessment#take_assessment'
  get '/ifa/lu/standards/show' => 'apps/assessment#topic_standards_benchmarks'
  get '/ifa/classroom/option/calibrate' => 'apps/assessment#classroom_option_toggle_calibrate'
  get '/ifa/classroom/option/filter' => 'apps/assessment#classroom_option_toggle_user_filter'
  get '/ifa/classroom/option/update' => 'apps/assessment#classroom_options_update'
  get '/ifa/classroom/assessment/pool/update' => 'apps/assessment#update_classroom_assessment_pool_from_repository'
  get '/ifa/classroom/assessments/filtered' => 'apps/assessment#classroom_get_filtered_assessments'

  # APP CTL
  get '/ctl/session/show' => 'apps/time_learning#static_itl_session'
  get '/ctl/subjects' => 'apps/time_learning#observation_subject_list'

  scope 'ctl/observation', as: 'ctl_observation' do
    get 'add' => 'apps/time_learning#setup_session'
    post 'add' => 'apps/time_learning#setup_session'
    get 'destroy' => 'apps/time_learning#destroy_session'
    get 'log' => 'apps/time_learning#log_summary'
    get 'finalize' => 'apps/time_learning#finalize_session'
    post 'survey' => 'apps/time_learning#take_post_conf_survey'
  end
  # get '/ctl/observation/add' => 'apps/time_learning#setup_session'
  # post '/ctl/observation/add' => 'apps/time_learning#setup_session'
  # get '/ctl/observation/destroy' => 'apps/time_learning#destroy_session'
  # get '/ctl/observation/log' => 'apps/time_learning#log_summary'
  # get '/ctl/observation/finalize' => 'apps/time_learning#finalize_session'
  # post '/ctl/observation/survey' => 'apps/time_learning#take_post_conf_survey'
  get '/ctl/observation/comments/edit' => 'apps/time_learning#edit_session_comments'
  get '/ctl/observation/video/attach' => 'apps/time_learning#attach_embed_code'
  get '/ctl/observation/video/remove' => 'apps/time_learning#remove_embed_code'
  get '/ctl/observation/video/create' => 'apps/time_learning#create_training_video'
  get '/ctl/observation/video/show' => 'apps/shared#show_video'

  get '/ctl/observation/research' => 'apps/time_learning#research_summary'
  get '/ctl/observation/activities' => 'apps/time_learning#refresh_activity_summary'

  get '/ctl/observe/begin' => 'apps/panel#track_session'
  get '/ctl/observe/end' => 'apps/panel#end_session'
  get '/ctl/observe/abort' => 'apps/panel#abort_session'
  get '/ctl/observe/task/start' => 'apps/panel#start_session_task'
  get '/ctl/observe/task/stop' => 'apps/panel#stop_session_task'
  get '/ctl/observe/evidence/add' => 'apps/panel#log_no_time_session_task'
  get '/ctl/observe/evidence/delete' => 'apps/panel#remove_log'
  get '/ctl/observe/evidence/note' => 'apps/panel#update_log_note'

  get '/ctl/backlog' => 'apps/time_learning#subject_tlt_sessions'
  get '/ctl/invite/send' => 'apps/time_learning#send_invite'
  get '/ctl/analyze/period' => 'apps/time_learning#then_now'
  get '/ctl/analyze/utlization' => 'apps/time_learning#school_utilization'
  get '/ctl/reflection' => 'apps/time_learning#teacher_private_itl_dashboards'
  get '/ctl/reflection/dashboard/teacher' => 'apps/time_learning#teacher_itl_dashboards'
  get '/ctl/reflection/dashboard/toggle' => 'apps/time_learning#toggle_school_dashboard_details'
  get '/ctl/reflection/population' => 'apps/time_learning#population_stats'
  post '/ctl/reflection/diagnostics' => 'apps/time_learning#diagnostics'
  get '/ctl/reflection/diagnostics/history' => 'apps/time_learning#diagnostic_history'
  get '/ctl/reflection/feedback' => 'apps/time_learning#student_feedback'
  get '/ctl/history' => 'apps/time_learning#session_history'
  get '/ctl/resources/panel_help' => 'apps/time_learning#observation_panel_help'
  get '/ctl/resources/app' => 'apps/shared#show_app_resources'
  get '/ctl/resources/app/admin' => 'apps/shared#admin_app_resources'

  get '/ctl/options/training' => 'apps/time_learning#training_classroom'
  get '/ctl/options/training/assign' => 'apps/time_learning#define_training_room'
  get '/ctl/options/method/activate' => 'apps/time_learning#toggle_method'
  get '/ctl/options/method/template/activate' => 'apps/time_learning#toggle_template_method'
  get '/ctl/options/template/filter/activate' => 'apps/time_learning#toggle_template_filter'
  get '/ctl/options/templates' => 'apps/time_learning#manage_filters'
  get '/ctl/options/finalize' => 'apps/time_learning#toggle_finalize'
  get '/ctl/options/concurrent' => 'apps/time_learning#toggle_concurrent'
  get '/ctl/options/discussion' => 'apps/time_learning#toggle_conversation'
  get '/ctl/options/scheduling' => 'apps/time_learning#edit_schedule_url'
  get '/ctl/options/thresholds' => 'apps/time_learning#toggle_thresholds'
  get '/ctl/options/belts' => 'apps/time_learning#toggle_belt_ranking'
  get '/ctl/options/belts/manage' => 'apps/time_learning#manage_belt_rankings'
  get '/ctl/options/belts/manage/user' => 'apps/time_learning#manage_belt_user'
  get '/ctl/options/belts/user/update' => 'apps/time_learning#update_user_belt'

  get '/ctl/options/stats/window' => 'apps/time_learning#edit_option_window'

  get '/ctl/maint/strategies' => 'apps/owner_maintenance#owner_strategies'
  get '/ctl/maint/strategies/edit' => 'apps/owner_maintenance#owner_strategy_edit'
  post '/ctl/maint/strategies/edit' => 'apps/owner_maintenance#owner_strategy_update'
  get '/ctl/maint/strategies/evidence' => 'apps/owner_maintenance#owner_strategy_evidence'
  get '/ctl/maint/thresholds' => 'apps/owner_maintenance#owner_strategy_thresholds'
  get '/ctl/maint/thresholds/edit' => 'apps/owner_maintenance#owner_thresholds_edit'
  post '/ctl/maint/thresholds/edit' => 'apps/owner_maintenance#owner_thresholds_edit'
  get '/ctl/maint/blackbelts' => 'apps/owner_maintenance#owner_blackbelt_maint'
  get '/ctl/maint/blackbelts/video' => 'apps/owner_maintenance#owner_show_video_session'
  get '/ctl/maint/blackbelts/session' => 'apps/owner_maintenance#toggle_blackbelt_session'
  get '/ctl/maint/schools' => 'apps/owner_maintenance#ctl_school_listing'
  get '/ctl/maint/schools/teachers' => 'apps/owner_maintenance#ctl_school_teacher_listing'
  get '/ctl/maint/schools/teacher/sessions' => 'apps/owner_maintenance#ctl_teacher_sessions'
  get '/ctl/maint/discussion' => 'apps/owner_maintenance#app_discussion_forum'
  get '/ctl/maint/discussion/update' => 'apps/owner_maintenance#update_app_discussion_parameters'
  get '/ctl/maint/dashboards' => 'apps/owner_maintenance#app_ctl_dashboards'
  get '/ctl/maint/dashboards/school' => 'apps/owner_maintenance#app_ctl_school_dashboard'
  get '/ctl/maint/dashboards/subject' => 'apps/owner_maintenance#app_ctl_school_subject_dashboards'
  get '/ctl/maint/dashboards/recalc' => 'apps/time_learning#recalc_itl_summary'
  get '/ctl/maint/sessions' => 'apps/owner_maintenance#app_ctl_open_sessions'
  get '/ctl/maint/sessions/school' => 'apps/owner_maintenance#app_ctl_school_opens'
  get '/ctl/maint/sessions/school/month' => 'apps/owner_maintenance#app_ctl_school_month_opens'
  get '/ctl/maint/sessions/month/deletes' => 'apps/owner_maintenance#destroy_open_sessions'
  get '/ctl/maint/sessions/month/delete' => 'apps/owner_maintenance#destroy_open_session'
  get '/ctl/maint/session/delete' => 'apps/owner_maintenance#ctl_destroy_session'

  # APP ELT
  get '/elt/maint/element/add' => 'apps/owner_maintenance#elt_element_add'
  get '/elt/maint/element/new' => 'apps/owner_maintenance#elt_element_new'
  post '/elt/maint/element/new' => 'apps/owner_maintenance#elt_element_new'
  get '/elt/maint/element/edit' => 'apps/owner_maintenance#elt_element_edit'
  post '/elt/maint/element/update' => 'apps/owner_maintenance#elt_element_update'
  get '/elt/maint/element/toggle' => 'apps/owner_maintenance#elt_toggle_active_element' # Is this as real link?
  get '/elt/maint/element/activate' => 'apps/owner_maintenance#toggle_element'
  get '/elt/maint/indicator/add' => 'apps/owner_maintenance#elt_indicator_add'
  get '/elt/maint/indicator/edit' => 'apps/owner_maintenance#elt_indicator_elt'
  post '/elt/maint/indicator/update' => 'apps/owner_maintenance#elt_indicator_update'
  get '/elt/maint/indicator/toggle' => 'apps/owner_maintenance#toggle_indicator' # Is this a real link?
  get '/elt/maint/indicator/activate' => 'apps/owner_maintenance#elt_toggle_indicator'
  get '/elt/maint/indicator/new' => 'apps/owner_maintenance#elt_indicator_new'
  post '/elt/maint/indicator/new' => 'apps/owner_maintenance#elt_indicator_new'
  get '/elt/maint/indicators' => 'apps/owner_maintenance#elt_manage_indicators'
  get '/elt/maint/activity/select' => 'apps/owner_maintenance#elt_select_type'

  get '/elt/case/add' => 'apps/learning_time#start_case'
  post '/elt/case/add' => 'apps/learning_time#start_case'
  get '/elt/case/show' => 'apps/learning_time#show_case'
  get '/elt/case/finalize' => 'apps/learning_time#toggle_finalize_case'
  get '/elt/map/evidence/show' => 'apps/learning_time#show_evidence_map'
  get '/elt/map/activity/show' => 'apps/learning_time#show_activity_map'
  get '/elt/case/header/update' => 'apps/learning_time#assign_case_header'
  post '/elt/case/update' => 'apps/learning_time#update_case_b'
  get '/elt/case/comments' => 'apps/learning_time#list_case_comments'
  get '/elt/case/support/findings' => 'apps/learning_time_standards#supporting_findings'

  get '/elt/config/standards' => 'apps/learning_time_standards#index'
  post '/elt/config/standard/add' => 'apps/learning_time_standards#create'
  get '/elt/config/standard/destroy' => 'apps/learning_time_standards#destroy'
  get '/elt/config/standard/activate' => 'apps/learning_time_standards#toggle_active'
  get '/elt/config/standard/public' => 'apps/learning_time_standards#toggle_public'
  get '/elt/config/standard/update' => 'apps/learning_time_standards#update'
  get '/elt/config/standard/element/add' => 'apps/learning_time_standards#new_element'
  get '/elt/config/standard/element/activate' => 'apps/learning_time_standards#toggle_element_active'
  get '/elt/config/standard/element/edit' => 'apps/learning_time_standards#edit_element'
  post '/elt/config/standard/element/update' => 'apps/learning_time_standards#update_element'
  get '/elt/config/standard/element/indicator/edit' => 'apps/learning_time_standards#edit_indicator'
  get '/elt/config/standard/element/indicator/activate' => 'apps/learning_time_standards#toggle_indicator_active'
  get '/elt/config/standard/element/indicator/add' => 'apps/learning_time_standards#new_indicator'
  post '/elt/config/standard/element/indicator/add' => 'apps/learning_time_standards#create_indicator'
  post '/elt/config/standard/element/indicator/update' => 'apps/learning_time_standards#update_indicator'
  get '/elt/config/standard/element/indicator/desc/update' => 'apps/learning_time_standards#update_descriptor'
  get '/elt/config/standard/element/indicator/desc/destroy' => 'apps/learning_time_standards#destroy_descriptor'
  get '/elt/config/cycles' => 'apps/learning_time#manage_cycles'
  get '/elt/config/cycle/edit' => 'apps/learning_time#maintain_cycle'
  post '/elt/config/cycle/edit' => 'apps/learning_time#maintain_cycle'
  get '/elt/config/cycle/activate' => 'apps/learning_time#toggle_active_cycle'
  get '/elt/config/cycle/framework/assign' => 'apps/learning_time#assign_framework_cycle'
  get '/elt/config/cycle/activity/assign' => 'apps/learning_time#assign_cycle_activity'
  get '/elt/config/cycle/element/assign' => 'apps/learning_time#assign_cycle_element'
  get '/elt/config/activities' => 'apps/learning_time#manage_activities'
  get '/elt/config/activity/edit' => 'apps/learning_time#maintain_activity'
  post '/elt/config/activity/edit' => 'apps/learning_time#maintain_activity'
  get '/elt/config/activity/rubric/activate' => 'apps/learning_time#toggle_rubric'
  get '/elt/config/activity/rubric/share' => 'apps/learning_time#share_rubric'
  get '/elt/config/activity/rubric/delete' => 'apps/learning_time#delete_rubric'
  get '/elt/config/indicators' => 'apps/learning_time#manage_indicators'
  get '/elt/config/indicator/activity/source' => 'apps/learning_time#select_source_activity'
  get '/elt/config/indicator/activity/target' => 'apps/learning_time#select_activity'
  get '/elt/config/indicator/copy' => 'apps/learning_time#copy_activity_indicators'
  get '/elt/config/indicator/element/select' => 'apps/learning_time#select_element'
  get '/elt/config/indicator/edit' => 'apps/learning_time#maintain_indicator'
  post '/elt/config/indicator/edit' => 'apps/learning_time#maintain_indicator'
  get '/elt/config/indicator/refresh' => 'apps/learning_time#refresh_element_indicator'
  get '/elt/config/indicators/disabled/destroy' => 'apps/learning_time#destroy_disabled_indicators'
  get '/elt/config/indicator/activate' => 'apps/learning_time#toggle_active_indicator'
  get '/elt/config/indicator/move' => 'apps/learning_time#move_indicator'
  get '/elt/config/indicator/support/assign' => 'apps/learning_time#assign_supported_indicator'
  get '/elt/config/indicator/clarifier/assign' => 'apps/learning_time#assign_clarifying_lookfor'
  get '/elt/config/indicator/destroy' => 'apps/learning_time#destroy_lookfor'
  get '/elt/config/plans' => 'apps/learning_time#manage_plan_types'
  get '/elt/config/plan/edit' => 'apps/learning_time#maintain_plan_type'
  post '/elt/config/plan/edit' => 'apps/learning_time#maintain_plan_type'
  get '/elt/config/plan/activate' => 'apps/learning_time#toggle_active_plan_type'
  get '/elt/config/cases/xfer' => 'apps/learning_time#transfer_cases'
  get '/elt/config/case/organization' => 'apps/learning_time#transfer_case_org'
  get '/elt/config/plans/xfer' => 'apps/learning_time#transfer_plans'
  get '/elt/config/plan/organization' => 'apps/learning_time#transfer_plan_org'
  get '/elt/activity/cycle/school/cases' => 'apps/learning_time#show_school_cycle_activity_cases' #
  get '/elt/activity/cycle/school/activities' => 'apps/learning_time#list_school_cycle_activities' #

  get '/elt/survey/start' => 'apps/learning_time#send_school_cycle_survey'
  get '/elt/survey/stop' => 'apps/learning_time#stop_school_cycle_surveys'
  get '/elt/community/filters' => 'apps/learning_time#select_kb_filters'
  get '/elt/community/indicator/rubric' => 'apps/learning_time#case_indicators_element_rubric'
  get '/elt/report' => 'apps/app_report#elt_school_diag'
  get '/elt/report/school/plan' => 'apps/app_report#elt_school_plan'
  get '/elt/report/school/cycle/plan' => 'apps/learning_time#school_cycle_plan'
  get '/elt/report/school/select' => 'apps/app_report#elt_select_school_for_diag'
  get '/elt/report/school/cycle/select' => 'apps/app_report#elt_select_cycle_for_school'
  get '/elt/report/school/activity/select' => 'apps/app_report#elt_select_activity_for_school'
  get '/elt/report/school/plan/destroy' => 'apps/app_report#elt_destroy_plan'
  get '/elt/report/school/plan/update' => 'apps/learning_time#update_action_plan'
  get '/elt/report/school/other/cycles' => 'apps/app_report#elt_other_school_cycles'

  get '/elt/option/cycle' => 'apps/learning_time#assign_option_cycle'


  # APP STAT
  scope 'stat/', as: 'stat' do
    get '/case' => 'apps/school_time#maintain_ista_case'
    post '/case' => 'apps/school_time#maintain_ista_case'
    post '/case/step/mins' => 'apps/school_time#step_update_mins'
    post '/case/step/hours' => 'apps/school_time#step_update_hours'
    get '/case/show' => 'apps/school_time#ista_case_show'
    get '/case/step/finish' => 'apps/school_time#finish_step'
    post '/case/finalize' => 'apps/school_time#finalize_case'
    get '/case/destroy' => 'apps/school_time#destroy_case'
    get '/dashboard' => 'apps/school_time#ista_dashboard'
    get '/dashboard/select' => 'apps/school_time#select_school_dashboard'
    get '/options/baseline' => 'apps/school_time#options_baselines'
    get '/options/baseline/maintain' => 'apps/school_time#maintain_baselines'
  end
  # PDF
  get '/pdf/elt/case' => 'apps/app_pdf#elt_case'
  #=======================================================

  # Victor add next two line just for test
  # map.connect '/static_organization/:organization_id/:id', :controller => 'site/site', :action => 'static_organization', :requirements => {:organization_id => /[a-f\d]{16}/}
  # map.connect '/static_resource/:organization_id/:id', :controller => 'site/site', :action => 'static_resource', :requirements => {:organization_id => /[a-f\d]{16}/}
  # map.connect '/static_classroom/:organization_id/:id', :controller => 'site/site', :action => 'static_classroom', :requirements => {:organization_id => /[a-f\d]{16}/}

  #  map.connect  '/users/edit_picture/:organization_id', :controller => 'users/assessment', :action => 'edit_picture'
  map.resources :classrooms

  map.resources :content_resource_types


  map.resources :messages
  map.resources :contact_fs_ns
  map.resources :organization_types, :controller => "master/organization_types"
  map.resources :organization_sizes, :controller => "master/organization_sizes"
  map.resources :address_types, :controller => "master/address_types"
  map.resources :act_submissions, :controller => "master/act_submissions"
  map.resources :act_submissions, :controller => "master/trt_session"
  map.resources :coop_apps, :controller => "master/coop_apps"

  #  map.admin_classroom_archive '/admin/classrooms/archive/:id',:controller => 'admin/classrooms',:action => 'archive'
  #  map.admin_classroom_restore '/admin/classrooms/restore/:id',:controller => 'admin/classrooms',:action => 'restore'
  #map.namespace :admin do |admin|
  #  admin.resources :donations

  #    admin.resources :classrooms
  #end

  map.namespace :master do |master|
    master.resources :merchant_accounts
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  #  map.connect 'NCTL', :controller => 'site/site', :action => 'static_organization', :organization_id => 'e9826fddf20737fd'

  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  #     map.resources :blogs
  #     map.connect '/blogs', :controller => 'site/blogs', :action => 'index'
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "fsn"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connet '/site/prayer_pledges/register', :controller => 'site/prayer_pledges', :action => 'index'
  # ALK
  map.connect '/apps/assessment', :controller => 'apps/assessment'
  map.connect '/apps/blogs', :controller => 'apps/blogs'
  map.connect '/apps/app_blog', :controller => 'apps/app_blog'
  map.connect '/apps/time_learning', :controller => 'apps/time_learning'
  map.connect '/apps/school_time', :controller => 'apps/school_time'
  map.connect '/apps/client_manager', :controller => 'apps/client_manager'
  map.connect '/apps/learning_time', :controller => 'apps/learning_time'
  map.connect '/apps/panel', :controller => 'apps/panel'
  #  map.connect  '/apps/classroom', :controller => 'apps/classroom'
  map.connect '/apps/staff_develop', :controller => 'apps/staff_develop'
  map.connect '/apps/shared', :controller => 'apps/shared'
  map.connect '/site/blog_posts', :controller => 'site/blog_posts'
  map.connect '/site/contents', :controller => 'site/contents'
  map.connect '/site/:organization_id', :controller => 'site/site', :action => 'index', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect '/site/site', :controller => 'fsn', :action => 'index'
  map.connect '/site/', :controller => 'site/site', :action => 'index'

  #  map.connect '/admin/', :controller => 'admin/application', :action => 'index'
  #  map.connect '/admin/application/index/:organization_id',  :controller => 'admin/application', :action => 'index', :requirements => {:organization_id => /[a-f\d]{16}/}
  ##  map.connect '/admin/:organization_id',  :controller => 'admin/application', :action => 'index', :requirements => {:organization_id => /[a-f\d]{16}/}
  # map.connect '/admin/:controller/:action/:organization_id', :requirements => {:organization_id => /[a-f\d]{16}/}
  # map.connect '/admin/:controller/:action/:organization_id/:id', :requirements => {:organization_id => /[a-f\d]{16}/}

  # map.connect '/master/', :controller => 'master/application', :action => 'index'

  map.connect ':controller/:action/:organization_id', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect ':controller/:action/:organization_id/:id', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect ':controller/:action/:organization_id.:format', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect ':id/blog/:year/:month/:day/:title', :controller => 'site/blog_posts', :action => 'show', :id => :id
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
end
