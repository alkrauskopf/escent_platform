EscentPartners::Application.routes.draw do |map|

#  mount Wirispluginengine::Engine => 'wirispluginengine'
  # You can have the root of your site routed with "root"
 # root to: 'fsn#index'

  get '/' => 'fsn#index'
  get '/root' => 'fsn#index'
  get '/privacy' => 'fsn#privacy'   #   privacy_path
  get '/terms' => 'fsn#terms'   #   terms_path

  # <%= link_to 'Edit Profile', user_edit_path %>
  #     <a href="/profile/edit">Edit Profile</a>

  # <%= link_to 'Edit Profile', profile_edit_url %>
  #     <a href="http://localhost:3000/profile/edit">Edit Profile</a>
  #   *** USE THIS IN ANY MAILERS ***

  #  CORE Main Page
  get '/ep' => 'fsn#index'
  get '/ep/blog/view' => 'fsn#select_blog'
  get '/ep/tos' => 'fsn#terms'
  get 'iwing/stylesheet' => 'stylesheets#iwing'
 # get '/:vanity' => 'application#vanity'

  # CORE User
  get '/user/registration/successful' => 'users#registration_successful'   #  user_registration_successful_path
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
#  get '/resource/view' => 'site/site#static_resource'    #  resource_view_path
  get '/resource/view' => 'apps/resource_library#static_resource'    #  resource_view_path
  get '/resource/new' => 'site/contents#submit_resource'
  post '/resource/new' => 'site/contents#submit_resource'
  get '/resource/show' => 'site/contents#index'
  get '/resource/edit' => 'site/contents#edit_resource'   #   resource_edit_path
  post '/resource/edit' => 'site/contents#edit_resource'
  get '/resource/assess/edit' => 'site/contents#edit_assess'   #  resource_assess_edit_path
  get '/resource/subjects' => 'site/contents#select_subject_areas'
  get '/resource/types' => 'site/contents#select_resource_types'
  get '/resource/share' => 'site/discussions#share_content'
  post '/resource/share' => 'site/discussions#share_content'
  get '/resource/group/show' => 'site/contents#show_group_content'
  get '/resource/group/select' => 'site/contents#select_content_group'
  put '/resource/destroy' => 'site/contents#destroy_selected'

  # CORE Organization
#  get '/organization/view' => 'site/site#static_organization', :requirements => {:organization_id => /[a-f\d]{16}/}  #  organization_view_path
  get '/organization/view' => 'apps/organization#static_organization', :requirements => {:organization_id => /[a-f\d]{16}/}  #  organization_view_path
  get '/organization/view/app' => 'apps/organization#summarize_org_app'   #  organization_view_app_path
 # get '/organization/view/app' => 'site/site#summarize_org_app'   #  organization_view_app_path
#  get '/organization/view/offering' => 'site/site#summarize_org_subject_offerings'    #   organization_view_offering_path
  get '/organization/view/offering' => 'apps/organization#summarize_org_subject_offerings'    #   organization_view_offering_path
  get '/organization/view/resources' => 'site/site#summarize_org_resources'

  # CORE Search
  get '/search' => 'site/site#search'
  post '/search' => 'site/site#search'
  get '/site/content/search' => 'site/site#search'
  get '/search/autocomplete' => 'site/site#keywords_autocomplete'

  # CORE Admin
  get '/admin' => 'admin/application#index'
  post '/admin' => 'admin/application#index'
  get '/admin/notify' => 'admin/our_organization#toggle_notification' #  admin_notify_path
  get '/admin/registration/allow' => 'admin/our_organization#toggle_registration_allow' #  admin_registration_allow_path
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
  get '/master/captcha' => 'master/captcha#index', as: 'master_captcha_images'
  get '/master/captcha/destroy' => 'master/captcha#destroy_captcha'
  post '/master/captcha' => 'master/captcha#create_captcha'
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
  get '/master/apps/edit' => 'master/coop_apps#edit_app'  # master_apps_edit_path
  post '/master/apps/edit' => 'master/coop_apps#edit_app'
  get '/master/apps/settings/edit' => 'master/coop_apps#edit_app_settings'
  post '/master/apps/settings/edit' => 'master/coop_apps#edit_app_settings'
  get '/master/ctl/video/show' => 'master/coop_apps#show_user_video_session'
  post '/master/ctl/strategies/edit' => 'master/coop_apps#ctl_strategy_update'
  get '/master/ctl/strategies' => 'master/coop_apps#ctl_strategies_maintain'
  get '/master/ctl/session' => 'master/coop_apps#ctl_strategies_maintain'
  get '/master/elt/orphan_elements' => 'master/coop_apps#elt_orphan_elements'

  # CORE Discussions
  get '/discussion/resource/comment/delete' => 'site/discussions#delete_resource_comment'
  post '/discussion/resource/comment/new' => 'site/discussions#add_comment_for_resource'
  get '/discussion/share' => 'site/discussions#share_discussion'
  post '/discussion/share' => 'site/discussions#share_discussion'
  get '/discussion/reply' => 'site/discussions#add_reply'     #   discussion_reply_url
  post '/discussion/reply' => 'site/discussions#add_reply'
  get '/discussion/reply/delete' => 'site/discussions#delete_reply'
  post '/discussion/comment/new' => 'site/discussions#add_comment'
  get '/discussion/report/abuse' => 'site/discussions#report_abuse'   # discussion_report_abuse_url
  post '/discussion/report/abuse' => 'site/discussions#report_abuse'

  # Main Application Route Paths
  get CoopApp.classroom.route_url => CoopApp.classroom.route_action    #  self.send(@current_application.link_path
  get CoopApp.ifa.route_url => CoopApp.ifa.route_action
  get CoopApp.ctl.route_url => CoopApp.ctl.route_action
  get CoopApp.pd.route_url => CoopApp.pd.route_action
  get CoopApp.ita.route_url => CoopApp.ita.route_action
  get CoopApp.stat.route_url => CoopApp.stat.route_action
  get CoopApp.cm.route_url => CoopApp.cm.route_action
  get CoopApp.elt.route_url => CoopApp.elt.route_action
  get CoopApp.blog.route_url => CoopApp.blog.route_action


  # APP Mainenance (New Approach)
  get '/app/maintenance/ifa' => 'app_maintenance/ifa#index' # app_maintenance_ifa_path
  get '/app/maintenance/ifa/std_select' => 'app_maintenance/ifa#standard_select' # app_maintenance_ifa_std_select_url
  get '/app/maintenance/ifa/strand_select' => 'app_maintenance/ifa#strand_select' # app_maintenance_ifa_strand_select_url
  get '/app/maintenance/ifa/strand/update' => 'app_maintenance/ifa#strand_update' # app_maintenance_ifa_strand_update_url
  get '/app/maintenance/ifa/strand/toggle' => 'app_maintenance/ifa#strand_toggle' # app_maintenance_ifa_strand_toggle_url
  get '/app/maintenance/ifa/strand/destroy' => 'app_maintenance/ifa#strand_destroy' # app_maintenance_ifa_strand_destroy_url
  get '/app/maintenance/ifa/subject/update' => 'app_maintenance/ifa#subject_update' # app_maintenance_ifa_subject_update_url
  get '/app/maintenance/ifa/strand/add' => 'app_maintenance/ifa#strand_add' # app_maintenance_ifa_strand_add_path
  post '/app/maintenance/ifa/strand/create' => 'app_maintenance/ifa#strand_create' # app_maintenance_ifa_strand_create_path
  get '/app/maintenance/ifa/level/add' => 'app_maintenance/ifa#level_add' # app_maintenance_ifa_level_add_path
  post '/app/maintenance/ifa/level/create' => 'app_maintenance/ifa#level_create' # app_maintenance_ifa_level_create_path
  get '/app/maintenance/ifa/standard/add' => 'app_maintenance/ifa#standard_add' # app_maintenance_ifa_standard_add_path
  post '/app/maintenance/ifa/standard/create' => 'app_maintenance/ifa#standard_create' # app_maintenance_ifa_standard_create_path
  get '/app/maintenance/ifa/master/select' => 'app_maintenance/ifa#standard_maint_select' # app_maintenance_ifa_master_select_url
  get '/app/maintenance/ifa/standard/destroy' => 'app_maintenance/ifa#standard_destroy' # app_maintenance_ifa_standard_destroy_url
  get '/app/maintenance/ifa/standard/update' => 'app_maintenance/ifa#standard_update' # app_maintenance_ifa_standard_update_url
  get '/app/maintenance/ifa/level_select' => 'app_maintenance/ifa#level_select' # app_maintenance_ifa_level_select_url
  get '/app/maintenance/ifa/level/update' => 'app_maintenance/ifa#level_update' # app_maintenance_ifa_level_update_url
  get '/app/maintenance/ifa/level/toggle' => 'app_maintenance/ifa#level_toggle' # app_maintenance_ifa_level_toggle_url
  get '/app/maintenance/ifa/level/destroy' => 'app_maintenance/ifa#level_destroy' # app_maintenance_ifa_level_destroy_url
  get '/app/maintenance/ifa/benchmark/add' => 'app_maintenance/ifa#benchmark_add' # app_maintenance_ifa_benchmark_add_path
  post '/app/maintenance/ifa/benchmark/add' => 'app_maintenance/ifa#benchmark_add' # app_maintenance_ifa_benchmark_add_path
  post '/app/maintenance/ifa/benchmark/create' => 'app_maintenance/ifa#benchmark_create' # app_maintenance_ifa_benchmark_create_path
  get '/app/maintenance/ifa/benchmark/edit' => 'app_maintenance/ifa#benchmark_edit' # app_maintenance_ifa_benchmark_edit_path
  get '/app/maintenance/ifa/benchmark/toggle' => 'app_maintenance/ifa#benchmark_toggle' # app_maintenance_ifa_benchmark_toggle_url
  get '/app/maintenance/ifa/benchmark/destroy' => 'app_maintenance/ifa#benchmark_destroy' # app_maintenance_ifa_benchmark_destroy_url
  get '/app/maintenance/ifa/benchmark/refresh' => 'app_maintenance/ifa#benchmark_refresh' # app_maintenance_ifa_benchmark_refresh_url
  post '/app/maintenance/ifa/benchmark/update' => 'app_maintenance/ifa#benchmark_update' # app_maintenance_ifa_benchmark_create_path
  get '/app/maintenance/ifa/benchmark/source' => 'app_maintenance/ifa#benchmark_source' # app_maintenance_ifa_benchmark_source_url
  get '/app/maintenance/ifa/genre/update' => 'app_maintenance/ifa#genre_update' # app_maintenance_ifa_genre_update_url
  get '/app/maintenance/ifa/genre/create' => 'app_maintenance/ifa#genre_create' # app_maintenance_ifa_genre_create_url
  post '/app/maintenance/options/edit' => 'app_maintenance/ifa#edit_options'    # app_maintenance_options_edit_path - - -OLD
  post '/ifa/options/edit' => 'app_maintenance/ifa#edit_options'    # ifa_options_edit_path
  get '/ifa/option/master/toggle' => 'app_maintenance/ifa#add_remove_standard_option'    # ifa_option_master_toggle_path
  get '/app/maintenance/ifa/classroom_select' => 'app_maintenance/ifa#classroom_select' # app_maintenance_ifa_classroom_select_url
  get '/app/maintenance/ifa/student_select' => 'app_maintenance/ifa#student_select' # app_maintenance_ifa_student_select_url
  post '/app/maintenance/ifa/edit_dashboard' => 'app_maintenance/ifa#edit_dashboard' # app_maintenance_ifa_edit_dashboard_url
  post '/app/maintenance/ifa/update_dashboard' => 'app_maintenance/ifa#update_dashboard' # app_maintenance_ifa_update_dashboard_url
  get '/app/maintenance/ifa/tool_a' => 'app_maintenance/ifa#tool_a' # app_maintenance_ifa_tool_a_url
  get '/app/maintenance/ifa/tool_b' => 'app_maintenance/ifa#tool_b' # app_maintenance_ifa_tool_b_url
  get '/app/maintenance/ifa/tool_c' => 'app_maintenance/ifa#tool_c' # app_maintenance_ifa_tool_c_url
  get '/app/maintenance/ifa/tool_d' => 'app_maintenance/ifa#tool_d' # app_maintenance_ifa_tool_d_url


  # APPS Shared
  get '/app/owner/maintenance' => 'apps/owner_maintenance#index'
  get '/survey/take' => 'apps/shared#take_survey'
  post '/survey/take' => 'apps/shared#take_survey'
  post '/survey/submit' => 'apps/shared#submit_survey'
  get '/my_survey/view' => 'apps/shared#my_surveys'   #  my_survey_view
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
  get '/surveys/results/show' => 'apps/shared#show_aggregated_results'   #  surveys_results_show_path

  get '/app/folder/edit' => 'apps/shared#edit_folder'   #  app_folder_edit_path
  post '/app/folder/edit' => 'apps/shared#edit_folder'   #  app_folder_edit_path
  get '/app/folder/new' => 'apps/shared#create_folder'
  get '/app/folder/destroy' => 'apps/shared#destroy_folder'  # app_folder_destroy_path
  get '/app/rubric/add' => 'apps/shared#maintain_rubric'  #app_rubric_add
  post '/app/rubric/add' => 'apps/shared#maintain_rubric'

  get '/app/resource/assign' => 'apps/shared#add_remove_resource'

  # APP Offering  (Classroom)
  # apps/class_offering
  get '/offering/view' => 'apps/class_offering#index'   # offering_view_path
  get '/offering/register' => 'apps/classroom#register_classroom'    # offering_register_path
  post '/self/offering/register' => 'apps/classroom#self_register_student'  # self_offering_register_path
  # site/site
#  get '/offering/view' => 'site/site#static_classroom'   # offering_view
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
  get '/offering/unjoin' => 'apps/classroom#self_unregister_student'   # offering_unjoin_path
#  get '/offering/register' => 'apps/classroom#register_classroom'
  get '/offering/lu/resources/show' => 'apps/classroom#show_lu_resources'   # offering_lu_resources_show
  get '/offering/admin/assign_subject' => 'apps/classroom#identify_parent_subject'
  get '/offering/admin/add' => 'apps/classroom#add_classroom'
  get '/offering/admin/subjects' => 'apps/classroom#subject_offerings'
  get '/offering/admin/setup' => 'apps/classroom#setup_classroom'
  get '/offering/admin/utilities' => 'apps/classroom#utilities'   # offering_admin_utilities_path
  get '/offering/admin/folder/destroy' => 'apps/classroom#admin_destroy_folder'  # offering_admin_folder_destroy_url
  get '/offering/admin/folders/copy' => 'apps/classroom#admin_folders_copy'  # offering_admin_folders_copy_url
  get '/offering/admin/offering/destroy' => 'apps/classroom#admin_destroy_offering'  # offering_admin_offering_destroy_url
  get '/offering/admin/offering/copy' => 'apps/classroom#admin_offering_copy'  # offering_admin_offering_copy_url
  post '/offering/admin/destroy' => 'apps/classroom#destroy_classroom'   # offering_admin_destroy_path
  get '/offering/admin/activate' => 'apps/classroom#toggle_active'
  get '/offering/admin/name/update' => 'apps/classroom#change_classroom_name'
  get '/offering/admin/subject/update' => 'apps/classroom#change_classroom_subject'
  get '/offering/admin/parent/subject' => 'apps/classroom#change_parent_subject'
  get '/offering/admin/periods' => 'apps/classroom#offering_periods'
  get '/offering/admin/period/add' => 'apps/classroom#add_period'
  get '/offering/admin/period/edit' => 'apps/classroom#edit_period'
  get '/offering/admin/period/teachers' => 'apps/classroom#manage_period_teachers'
  get '/offering/admin/period/destroy' => 'apps/classroom#destroy_period'
  get '/offering/admin/lus' => 'apps/classroom#offering_lus'   # offering_admin_lus_path
  get '/offering/admin/lu/add' => 'apps/classroom#add_lu'
  get '/offering/admin/lu/edit' => 'apps/classroom#setup_classroom_lu'
  post '/offering/admin/lu/edit' => 'apps/classroom#setup_classroom_lu'
  get '/offering/admin/lu/destroy' => 'apps/classroom#destroy_lu'
  get '/offering/admin/lu/options' => 'apps/classroom#toggle_lu_options'   # offering_admin_lu_options_url
  get '/offering/admin/lu/folder' => 'apps/shared#assign_lu_folder'     #  offering_admin_lu_folder_url
  get '/offering/admin/lu/folder/position' => 'apps/shared#assign_lu_folder_position'   #  offering_admin_lu_folder_position
  get '/offering/admin/lu/folder/toggle' => 'apps/shared#assign_lu_folder_toggle_show'   #  offering_admin_lu_folder_toggle
  get '/offering/admin/lu/strand' => 'apps/classroom#assign_lu_strand'     #  offering_admin_lu_strand_url
  get '/offering/admin/resources' => 'apps/classroom#offering_resources'     #  offering_admin_resources_path
  get '/offering/admin/strands' => 'apps/classroom#offering_strands'     #  offering_admin_strands_path
  get '/offering/admin/resource/assign' => 'apps/classroom#add_remove_resource'
  get '/offering/admin/resource/feature' => 'apps/classroom#toggle_lu_featured_resource'
  get '/offering/admin/folders' => 'apps/classroom#offering_folders'     #   offering_admin_folders_path
  get '/offering/folder/mastery' => 'apps/classroom#offering_folder_masteries'     #   offering_folder_mastery_path
  get '/offering/folder/benchmarks' => 'apps/classroom#offering_folder_benchmarks'     #   offering_folder_benchmarks_path
  get '/offering/folder/mastery/assign' => 'apps/classroom#offering_folder_mastery_assign'     #   offering_folder_mastery_assign_url
  get '/offering/admin/folder/setup' => 'apps/classroom#offering_folder_setup'
  get '/offering/folder/position/assign' => 'apps/shared#assign_folder_position'   #  offering_folder_position_assign_url
  get '/offering/folder/assign' => 'apps/shared#assign_offering_folder'   #  offering_folder_assign_url
  get '/offering/admin/resource/folder' => 'apps/classroom#lu_resource_folder'   #   offering_admin_resource_folder_path
  get '/offering/admin/resource/copy' => 'apps/classroom#copy_lu_resources'
  get '/offering/admin/resource/pool' => 'apps/classroom#resource_pool'
  get '/offering/admin/referrals' => 'apps/classroom#offering_referrals'
  get '/offering/admin/referral/assign' => 'apps/classroom#add_remove_referral'
  get '/offering/admin/students' => 'apps/classroom#offering_students'
  get '/offering/admin/students/period' => 'apps/classroom#manage_period_students'
  get '/offering/admin/students/remove/all' => 'apps/classroom#remove_all_students'
  get '/offering/admin/student/assign' => 'apps/classroom#add_remove_student'     #   offering_admin_student_assign
  get '/offering/admin/assessments' => 'apps/assessment#assign_classroom_assessment'   #  offering_admin_assessments
  get '/offering/admin/assessment/view' => 'apps/assessment#assign_classroom_assessment_view'   #   offering_admin_assessment_view
  get '/offering/admin/assessment/pool/update' => 'apps/assessment#update_classroom_assessment_pool'
  get '/offering/admin/surveys' => 'apps/classroom#offering_surveys'
  get '/offering/admin/survey/on' => 'apps/classroom#period_survey_activate'
  get '/offering/admin/survey/off' => 'apps/classroom#period_survey_deactivate'
  get '/offering/admin/homeworks' => 'apps/classroom#offering_homeworks'
  get '/offering/admin/option/activate' => 'apps/classroom#offering_options' # offering_admin_option_activate_url
  get '/offering/admin/homework/delete' => 'apps/classroom#delete_homework'
  get '/offering/admin/teacher' => 'apps/classroom#manage_teacher'
  get '/offering/admin/teacher/subject' => 'apps/classroom#assign_for_subject'
  get '/offering/admin/teacher/period/assign' => 'apps/classroom#assign_period_teacher_1'
  get '/offering/admin/student/teacher/select' => 'apps/classroom#select_teacher'

  # APP Blogs
  get '/blog/view' => 'apps/app_blog#show_app_blog'   # blog_view
  get '/blog/show' => 'site/blogs#show'       # blog_show
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

  get '/ifa/teacher/review' => 'apps/assessment#teacher_review'   # ifa_teacher_review_path
  get '/ifa/lu/standards/show' => 'apps/assessment#topic_standards_benchmarks'    #   ifa_lu_standards_show_path
  get '/ifa/classroom/option/calibrate' => 'apps/assessment#classroom_option_toggle_calibrate'
  get '/ifa/classroom/option/filter' => 'apps/assessment#classroom_option_toggle_user_filter'
  get '/ifa/classroom/option/update' => 'apps/assessment#classroom_options_update'
  get '/ifa/classroom/assessment/pool/update' => 'apps/assessment#update_classroom_assessment_pool_from_repository'   # ifa_classroom_assessment_pool_update_path
  get '/ifa/classroom/assessments/filtered' => 'apps/assessment#classroom_get_filtered_assessments'
  get '/ifa/students' => 'apps/assessment#student_list'    # ifa_students_path
  get '/ifa/pending_destroy' => 'apps/assessment#destroy_pending'    # ifa_pending_destroy_url
  get '/ifa/pending_destroy_all' => 'apps/assessment#destroy_pending_all'    # ifa_pending_destroy_url
  get '/ifa/org_analysis' => 'apps/assessment#org_analysis'    # ifa_org_analysis_path
  post '/ifa/org_analysis' => 'apps/assessment#org_analysis'    # ifa_org_analysis_path
  get '/ifa/toggle/summary_data' => 'apps/assessment#toggle_sumry_ifa_data'    # ifa_toggle_summary_data_url
  get '/ifa/toggle/sat_view' => 'apps/assessment#toggle_sat_view'    # ifa_toggle_sat_view_url
  get '/ifa/toggle/sat_view/student' => 'apps/assessment#toggle_sat_view_student'    # ifa_toggle_sat_view_student
  get '/ifa/toggle/summary_dashboard' => 'apps/assessment#toggle_sumry_ifa_dashboard'    # ifa_toggle_summary_dashboard_url
  post '/ifa/manual/update' => 'apps/assessment#manual_ifa_update'    # ifa_manual_update_path
  post '/ifa/submission/add' => 'apps/assessment#add_submission'    # ifa_submission_add_path

  get '/ifa/student/baseline/edit' => 'apps/assessment#edit_student_baseline_score' #  ifa_student_baseline_edit_url
  get '/ifa/student/csap/demographic/edit' => 'apps/assessment#edit_student_csap_demographic' #  ifa_student_csap_demographic_edit_url
  get '/ifa/student/demographic/update' => 'apps/assessment#update_student_demographics' #  ifa_student_demographic_update_path
  get '/ifa/student/grade_level/edit' => 'apps/assessment#edit_student_grade_level' #  ifa_student_grade_level_edit_url

  get '/ifa/question/show' => 'apps/assessment#static_question'    # ifa_question_show_path
  get '/ifa/question/preview' => 'apps/assessment#preview_question'    # ifa_question_preview_path
  get '/ifa/question/add' => 'apps/assessment#add_ifa_question'    # ifa_question_add_path
  post '/ifa/question/add' => 'apps/assessment#add_ifa_question'    # ifa_question_add_path
  post '/ifa/question/create' => 'apps/assessment#add_question'    # ifa_question_create_path
  get '/ifa/question/edit' => 'apps/assessment#edit_ifa_question'    # ifa_question_edit_path
  post '/ifa/question/edit' => 'apps/assessment#edit_ifa_question'    # ifa_question_edit_path
  post '/ifa/question/update' => 'apps/assessment#edit_question'    # ifa_question_update_path
  get '/ifa/question/destroy' => 'apps/assessment#edit_question_destroy_question'    # ifa_question_destroy_url
  get '/ifa/question/position' => 'apps/assessment#position_question'    # ifa_question_position_url
  get '/ifa/question/pool/recycle' => 'apps/assessment#edit_assessment_question_pool_recycle' #  ifa_question_pool_recycle_url
  get '/ifa/question/options/recycle' => 'apps/assessment#edit_question_options_recycle' #  ifa_question_options_recycle_url
  get '/ifa/question/choice/update' => 'apps/assessment#edit_question_update_choice' #  ifa_question_choice_update_url
  get '/ifa/question/choice/add' => 'apps/assessment#edit_question_add_choice' #  ifa_question_choice_add_url
  get '/ifa/question/choice/remove' => 'apps/assessment#edit_question_remove_choice' #  ifa_question_choice_remove_path
  get '/ifa/question/choice/delete' => 'apps/assessment#remove_choice' #  ifa_question_choice_delete_path
  get '/ifa/question/copy' => 'apps/assessment#copy_question' #  ifa_question_copy_path
  post '/ifa/question/copy' => 'apps/assessment#copy_question' #  ifa_question_copy_path

  get '/ifa/question/choice/toggle' => 'apps/assessment#edit_question_toggle_choice' #  ifa_question_choice_toggle_path
  get '/ifa/question/reading' => 'apps/assessment#get_question_reading' #  ifa_question_reading_url
  get '/ifa/question/reading/add' => 'apps/assessment#add_reading' #  ifa_question_reading_add_path
  post '/ifa/question/reading/add' => 'apps/assessment#add_reading' #  ifa_question_reading_add_path
  get '/ifa/question/score/range' => 'apps/assessment#edit_question_score_range' #  ifa_question_score_range_url
  get '/ifa/question/strand' => 'apps/assessment#edit_question_strand' #  ifa_question_strand_url
  get '/ifa/question/master/new' => 'apps/assessment#edit_question_new_master' #  ifa_question_master_new_url
  get '/ifa/question/benchmarks/recycle' => 'apps/assessment#edit_question_benchmarks_recycle' #  ifa_question_benchmarks_recycle_url
  get '/ifa/question/assessments/recycle' => 'apps/assessment#edit_question_assessments_recycle' #  ifa_question_assessments_recycle_url
  get '/ifa/question/assessments/remove' => 'apps/assessment#edit_question_remove_assessment' #  ifa_question_assessments_remove_path
  get '/ifa/question/assessments/attach' => 'apps/assessment#edit_question_attach_assessment' #  ifa_question_assessments_attach_path
  get '/ifa/question/resources/find' => 'apps/assessment#edit_question_find_resources' #  ifa_question_resources_find_url
  get '/ifa/question/resource/remove' => 'apps/assessment#edit_question_remove_resource' #  ifa_question_resource_remove_path
  get '/ifa/question/resource/attach' => 'apps/assessment#edit_question_attach_resource' #  ifa_question_resource_attach_path
  get '/ifa/question/toggle/lock' => 'apps/assessment#edit_question_toggle_lock' #  ifa_question_toggle_lock_url
  get '/ifa/question/toggle/active' => 'apps/assessment#edit_question_toggle_active' #  ifa_question_toggle_active_url
  get '/ifa/question/picture/size' => 'apps/assessment#edit_question_picture_enlarge' #  ifa_question_picture_size_url
  get '/ifa/question/benchmark/remove' => 'apps/assessment#edit_question_remove_benchmark' #  ifa_question_benchmark_remove_path
  get '/ifa/question/benchmark/add' => 'apps/assessment#edit_question_add_benchmark' #  ifa_question_benchmark_add_path
  get '/ifa/question/toggle/calibration' => 'apps/assessment#toggle_question_calibration' #  ifa_question_toggle_calibration_path

  get '/ifa/user/assessments/list' => 'apps/assessment#list_user_assessments'    # ifa_user_assessments_list_path
  get '/ifa/user/questions/list' => 'apps/assessment#list_user_questions'    # ifa_user_questions_list_path
  get '/ifa/user/options/update' => 'apps/assessment#user_options_update' #  ifa_user_options_update_url
  get '/ifa/user/options/assessment/update' => 'apps/assessment#static_assess_user_options_update' #  ifa_user_options_assessment_update_url
  get '/ifa/user/options/toggle/calibrate' => 'apps/assessment#user_option_toggle_calibrate' #  ifa_user_options_toggle_calibrate_url
  get '/ifa/user/options/toggle/filter' => 'apps/assessment#user_option_toggle_user_filter' #  ifa_user_options_toggle_filter_url
  get '/ifa/user/switch/standard' => 'apps/assessment#switch_standard_view' #  ifa_user_switch_standard_url

  get '/ifa/plan/std/select' => 'ifa/ifa_plan#select_standard' #  ifa_plan_std_select_url
  get '/ifa/plan/subject/select' => 'ifa/ifa_plan#select_subject' #  ifa_plan_subject_select_url
  get '/ifa/plan/subject' => 'ifa/ifa_plan#plan_subject' #  ifa_plan_subject_path
  get '/ifa/plan/create' => 'ifa/ifa_plan#plan_create' #  ifa_plan_create_url
  get '/ifa/plan/show/form' => 'ifa/ifa_plan#plan_show_form' #  ifa_plan_show_form_url
  get '/ifa/plan/update' => 'ifa/ifa_plan#plan_update' #  ifa_plan_update_url
  post '/ifa/plan/update' => 'ifa/ifa_plan#plan_update_2' #  ifa_plan_update_url
  get '/ifa/plan/update/cancel' => 'ifa/ifa_plan#plan_update_cancel' #  ifa_plan_update_cancel_url
  get '/ifa/milestone/create' => 'ifa/ifa_plan#milestone_create' #  ifa_milestone_create_url
  get '/ifa/milestone/update' => 'ifa/ifa_plan#milestone_update' #  ifa_milestone_update_url
  get '/ifa/milestone/update/cancel' => 'ifa/ifa_plan#milestone_update_cancel' #  ifa_milestone_update_cancel_url
  get '/ifa/milestone/range/select' => 'ifa/ifa_plan#milestone_range_select' # ifa_milestone_range_select_url
  get '/ifa/milestone/destroy' => 'ifa/ifa_plan#milestone_destroy' #  ifa_milestone_destroy_url
  get '/ifa/milestone/change' => 'ifa/ifa_plan#milestone_change' #  ifa_milestone_change_url
  get '/ifa/milestone/achieved' => 'ifa/ifa_plan#milestone_achieved' #  ifa_milestone_achieved_url
  get '/ifa/plan/teacher/review' => 'ifa/ifa_plan#plan_teacher_review' #  ifa_plan_teacher_review_path
  get '/ifa/milestone/achieve/toggle' => 'ifa/ifa_plan#milestone_achieve_toggle' #  ifa_milestone_achieve_toggle_url
  get '/ifa/remark/add' => 'ifa/ifa_plan#plan_teacher_remark_update' #  ifa_remark_add_url
  get '/ifa/remark/destroy' => 'ifa/ifa_plan#plan_teacher_remark_destroy' #  ifa_remark_destroy_url
  get '/ifa/remark/show/form' => 'ifa/ifa_plan#remark_show_form' #  ifa_remark_show_form_url
  get '/ifa/plan/student/cell/data' => 'ifa/ifa_plan#student_cell_data' #  ifa_plan_student_cell_data_path

  get '/ifa/repo/question/add' => 'ifa/question_repo#index'    # ifa_repo_question_add_path
  post '/ifa/repo/question/add' => 'ifa/question_repo#index'    # ifa_repo_question_add_path
  get '/ifa/repo/subject/select' => 'ifa/question_repo#subject_select'    # ifa_repo_subject_select_path
  post '/ifa/repo/question/create' => 'ifa/question_repo#create'    # ifa_repo_question_create_url
  get '/ifa/repo/question/edit' => 'ifa/question_repo#edit'    # ifa_repo_question_edit_path
  get '/ifa/repo/question/new' => 'ifa/question_repo#new'    # ifa_repo_question_new_url
  get '/ifa/repo/question/reading/select' => 'ifa/question_repo#reading_select'    # ifa_repo_question_reading_select_url
  get '/ifa/repo/question/strand/select' => 'ifa/question_repo#strand_select'    # ifa_repo_question_strand_select_url
  get '/ifa/repo/question/level/select' => 'ifa/question_repo#level_select'    # ifa_repo_question_level_select_url
  get '/ifa/repo/question/choice/create' => 'ifa/question_repo#choice_create'    # ifa_repo_question_choice_create_url
  get '/ifa/repo/question/choice/active' => 'ifa/question_repo#choice_active'    # ifa_repo_question_choice_active_url
  get '/ifa/repo/question/choice/correct' => 'ifa/question_repo#choice_correct'    # ifa_repo_question_choice_correct_url
  get '/ifa/repo/question/choice/destroy' => 'ifa/question_repo#choice_destroy'    # ifa_repo_question_choice_destroy_url
  get '/ifa/repo/question/choice/update' => 'ifa/question_repo#choice_update'    # ifa_repo_question_choice_update_url
  get '/ifa/repo/question/rl/select' => 'ifa/question_repo#rl_select'           # ifa_repo_question_rl_select_url
  get '/ifa/repo/question/resource/attach' => 'ifa/question_repo#resource_attach'    # ifa_repo_question_resource_attacht_url
  get '/ifa/repo/pool/select' => 'ifa/question_repo#question_list'    # ifa_repo_pool_select_path
  get '/ifa/repo/question/show' => 'ifa/question_repo#static_question'    # ifa_repo_question_show_path
  get '/ifa/repo/question/active' => 'ifa/question_repo#toggle_active'    # ifa_repo_question_active_url
  get '/ifa/repo/question/destroy' => 'ifa/question_repo#question_destroy'    # ifa_repo_question_destroy_url
  get '/ifa/repo/question/preview' => 'ifa/question_repo#preview_question'    # ifa_repo_question_preview_path
  get '/ifa/repo/question/assessment/select' => 'ifa/question_repo#assessment_select'    # ifa_repo_question_assessment_select_path
  get '/ifa/repo/question/benchmark/attach' => 'ifa/question_repo#benchmark_attach'    # ifa_repo_question_benchmark_attach_url

  get '/ifa/repo/assessment/add' => 'ifa/assessment_repo#index'    # ifa_repo_assessment_add_path
  post '/ifa/repo/assessment/add' => 'ifa/assessment_repo#index'    # ifa_repo_assessment_add_path
  get '/ifa/repo/assessment/subject/select' => 'ifa/assessment_repo#subject_select'    # ifa_repo_assessment_subject_select_path
  post '/ifa/repo/assessment/create' => 'ifa/assessment_repo#create'    # ifa_repo_assessment_create_url
  get '/ifa/repo/assessment/active' => 'ifa/assessment_repo#toggle_active'    # ifa_repo_assessment_active_url
  get '/ifa/repo/assessment/question/toggle' => 'ifa/assessment_repo#toggle_add_question'    # ifa_repo_assessment_question_toggle_url
  get '/ifa/repo/assessment/question/position' => 'ifa/assessment_repo#question_position_update'    # ifa_repo_assessment_question_position_url
  get '/ifa/repo/assessment/filter' => 'ifa/assessment_repo#pool_filter'    # ifa_repo_assessment_filter_url
  get '/ifa/repo/assessment/pool/select' => 'ifa/assessment_repo#assessment_list'    # ifa_repo_assessment_pool_select_path
  get '/ifa/repo/assessment/refresh' => 'ifa/assessment_repo#refresh'    # ifa_repo_assessment_refresh_path

  get '/ifa/assessment/take' => 'apps/assessment#take_assessment'    # ifa_assessment_take_path
  get '/ifa/assessment/edit' => 'apps/assessment#edit_ifa_assessment'   # ifa_assessment_edit_path
  post '/ifa/assessment/edit' => 'apps/assessment#edit_ifa_assessment'   # ifa_assessment_edit_path
  get '/ifa/assessment/update' => 'apps/assessment#edit_assessment'   # ifa_assessment_update_path
  post '/ifa/assessment/update' => 'apps/assessment#edit_assessment'   # ifa_assessment_update_path
  get '/ifa/assessment/copy' => 'apps/assessment#copy_assessment'   # ifa_assessment_copy_path
  get '/ifa/assessment/submission' => 'apps/assessment#submission_teacher'  # ifa_assessment_submission_url
  get '/ifa/assessment/submission/show' => 'apps/assessment#view_submission'  # ifa_assessment_submission_show_path
  get '/ifa/assessment/submit' => 'apps/assessment#submit_assessment'    # ifa_assessment_submit_path
  post '/ifa/assessment/submit' => 'apps/assessment#submit_assessment'    # ifa_assessment_submit_path
  get '/ifa/assessment/view' => 'apps/assessment#static_assessment'   # ifa_assessment_view_path
  post '/ifa/assessment/view' => 'apps/assessment#static_assessment'   # ifa_assessment_update_path
  post '/ifa/assessment/create' => 'apps/assessment#add_assessment'    # ifa_assessment_create_path
  # get '/ifa/assessment/add' => 'apps/assessment#add_assessment'    # ifa_assessment_add_path
  get '/ifa/assessment/add' => 'apps/assessment#add_ifa_assessment'    # ifa_assessment_add_path
  post '/ifa/assessment/add' => 'apps/assessment#add_ifa_assessment'    # ifa_assessment_add_path
  get '/ifa/assessment/review/final' => 'apps/assessment#final_assessment_review'    # ifa_assessment_review_final_path
  post '/ifa/assessment/review/final' => 'apps/assessment#final_assessment_review'    # ifa_assessment_review_final_path
  get '/ifa/assessment/options/recycle' => 'apps/assessment#edit_assessment_options_recycle' #  ifa_assessment_options_recycle_url
  get '/ifa/assessment/toggle/lock' => 'apps/assessment#edit_assessment_toggle_lock' #  ifa_assessment_toggle_lock_url
  get '/ifa/assessment/toggle/active' => 'apps/assessment#edit_assessment_toggle_active' #  ifa_assessment_toggle_active_url
  get '/ifa/assessment/destroy' => 'apps/assessment#edit_assessment_destroy_assessment' #  ifa_assessment_destroy_url
  get '/ifa/assessment/question/add' => 'apps/assessment#edit_assessment_add_question' #  ifa_assessment_question_add_path
  get '/ifa/assessment/question/remove' => 'apps/assessment#edit_assessment_remove_question' #  ifa_assessment_question_remove_path
  get '/ifa/assessment/question/analyze' => 'apps/assessment#static_assess_question_analysis' #  ifa_assessment_question_analyze_path
  get '/ifa/assessment/question/analyze/test' => 'apps/assessment#question_analysis_test' #  ifa_assessment_question_analyze_test_path
  get '/ifa/assessment/question/view/assign' => 'apps/assessment#assign_assessment_question_view' #  ifa_assessment_question_view_assign_path

  get '/ifa/dashboard/refresh/scores' => 'apps/assessment#refresh_dashboard_scores' #  ifa_dashboard_refresh_scores_url
  get '/ifa/dashboard/refresh/cells' => 'apps/assessment#refresh_dashboard_cells' #  ifa_dashboard_refresh_cells_url
  get '/ifa/dashboard/submissions' => 'apps/assessment#dashboard_submissions' #  ifa_dashboard_submissions_url
  get '/ifa/dashboard/tb/submissions' => 'apps/assessment#tbdashboard_submissions' #  ifa_dashboard_tb_submissions_url
  get '/ifa/dashboard/toggle' => 'apps/assessment#toggle_ifa_dashboard' #  ifa_dashboard_toggle_url
  get '/ifa/dashboard/growth' => 'apps/assessment#growth_dashboards' #  ifa_dashboard_growth_path
  get '/ifa/dashboard/entity' => 'apps/assessment#entity_dashboard' #  ifa_dashboard_entity_path
  get '/ifa/dashboard/range_change' => 'apps/assessment#range_change_dashboard' #  ifa_dashboard_range_change_url

  get '/ifa/dashboards/growth' => 'ifa/ifa_dashboard#growth_dashboards' #  ifa_dashboards_growth_path
  get '/ifa/dashboards/entity' => 'ifa/ifa_dashboard#entity_dashboard' #  ifa_dashboards_entity_path
  get '/ifa/dashboards/submissions' => 'ifa/ifa_dashboard#dashboard_submissions' #  ifa_dashboards_submissions_url

  get '/ifa/related_reading' => 'apps/assessment#get_related_reading' #  ifa_related_reading_url
  post '/ifa/related_reading/add' => 'apps/assessment#add_reading' #  ifa_related_reading_add_path
  get '/ifa/related_reading/select' => 'apps/assessment#select_related_reading' #  ifa_related_reading_select_url
  get '/ifa/related_reading/edit' => 'apps/assessment#edit_reading' #  ifa_related_reading_edit_path
  post '/ifa/related_reading/edit' => 'apps/assessment#edit_reading' #  ifa_related_reading_edit_path
  get '/ifa/related_reading/genre/show' => 'apps/assessment#genre_readings' #  ifa_related_reading_genre_show_path
  get '/ifa/related_reading/destroy' => 'apps/assessment#destroy_reading' #  ifa_related_reading_destroy_path
  post '/ifa/related_reading/destroy' => 'apps/assessment#destroy_reading' #  ifa_related_reading_destroy_path

  get '/ifa/benchmark/ifa/add' => 'apps/assessment#add_ifa_benchmark'   # ifa_benchmark_ifa_add_path
  post '/ifa/benchmark/ifa/add' => 'apps/assessment#add_ifa_benchmark'   # ifa_benchmark_ifa_add_path
  post '/ifa/benchmark/add' => 'apps/assessment#add_benchmark' #  ifa_benchmark_add_path
  get '/ifa/benchmark/edit' => 'apps/assessment#edit_ifa_benchmark'   # ifa_benchmark_edit_path
  post '/ifa/benchmark/edit' => 'apps/assessment#edit_ifa_benchmark'   # ifa_benchmark_edit_path
  post '/ifa/benchmark/update' => 'apps/assessment#edit_benchmark'   # ifa_benchmark_update_path
  get '/ifa/benchmark/show' => 'apps/assessment#static_benchmark'   # ifa_benchmark_show_path
  get '/ifa/benchmark/destroy' => 'apps/assessment#destroy_benchmark'   # ifa_benchmark_destroy_path

  get '/ifa/subject/questions' => 'apps/assessment#subject_questions'    # ifa_subject_questions_path
  get '/ifa/subject/assessments/list' => 'apps/assessment#list_subject_assessments'    # ifa_subject_assessments_list_path
  get '/ifa/subject/benchmarks' => 'apps/assessment#subject_benchmarks'    # ifa_subject_benchmarks_path
  get '/ifa/subject/standard/benchmarks' => 'apps/assessment#subject_standard_benchmarks'    # ifa_subject_standard_benchmarks_path
  get '/ifa/subject/readings' => 'apps/assessment#subject_readings'    # ifa_subject_readings_path

  get '/ifa/standard/questions/list' => 'apps/assessment#list_standard_questions'    # ifa_standard_questions_list_path



  get 'ifa/co/subject/standards' => 'apps/co_standard#subject_standards'    #   ifa_co_subject_standards_path

  # APP CTL
  get '/ctl/session/show' => 'apps/time_learning#static_itl_session'
  get '/ctl/subjects' => 'apps/time_learning#observation_subject_list'   # ctl_subjects_path

  scope 'ctl/observation', as: 'ctl_observation' do
    get 'add' => 'apps/time_learning#setup_session'   # ctl_observation_add_path
    post 'add' => 'apps/time_learning#setup_session'
    get 'destroy' => 'apps/time_learning#destroy_session'
    get 'log' => 'apps/time_learning#log_summary'    #   ctl_observation_log_path
    get 'finalize' => 'apps/time_learning#finalize_session'
    post 'survey' => 'apps/time_learning#take_post_conf_survey'
    get 'survey/send' => 'apps/time_learning#send_student_survey_from_static_page'
  end
  get '/ctl/observation/comments/edit' => 'apps/time_learning#edit_session_comments'  #   ctl_observation_comments_edit_path
  get '/ctl/observation/video/attach' => 'apps/time_learning#attach_embed_code'
  get '/ctl/observation/video/remove' => 'apps/time_learning#remove_embed_code'
  get '/ctl/observation/video/create' => 'apps/time_learning#create_training_video'   # ctl_observation_video_create_path
  get '/ctl/observation/video/show' => 'apps/shared#show_video'    #  ctl_observation_video_show
  get '/ctl/observation/video/rl' => 'apps/time_learning#add_video_to_rl'    #  ctl_observation_video_rl
  get '/ctl/observation/research' => 'apps/time_learning#research_summary'    #  ctl_observation_research_path
  get '/ctl/observation/activities' => 'apps/time_learning#refresh_activity_summary'
  get '/ctl/observe/begin' => 'apps/panel#track_session'  #  ctl_observe_begin_path
  get '/ctl/observe/end' => 'apps/panel#end_session'
  get '/ctl/observe/abort' => 'apps/panel#abort_session'
  get '/ctl/observe/task/start' => 'apps/panel#start_session_task'
  get '/ctl/observe/task/stop' => 'apps/panel#stop_session_task'
  get '/ctl/observe/evidence/add' => 'apps/panel#log_no_time_session_task'
  get '/ctl/observe/evidence/delete' => 'apps/panel#remove_log'
  get '/ctl/observe/evidence/note' => 'apps/panel#update_log_note'
  get '/ctl/observe/evidence/strategy' => 'apps/panel#update_log_strategy'
  get '/ctl/backlog' => 'apps/time_learning#subject_tlt_sessions'
  get '/ctl/invite/send' => 'apps/time_learning#send_invite'
  get '/ctl/analyze/period' => 'apps/time_learning#then_now'
  get '/ctl/analyze/utlization' => 'apps/time_learning#school_utilization'
  get '/ctl/reflection' => 'apps/time_learning#teacher_private_itl_dashboards'
  get '/ctl/reflection/dashboard/teacher' => 'apps/time_learning#teacher_itl_dashboards'
  get '/ctl/reflection/dashboard/teacher/toggle' => 'apps/time_learning#toggle_teacher_dashboard_details'
  get '/ctl/reflection/dashboard/toggle' => 'apps/time_learning#toggle_school_dashboard_details'
  get '/ctl/reflection/dashboard/subject' => 'apps/time_learning#subject_dashboard'
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
  get '/ctl/options/template/toggle' => 'apps/time_learning#toggle_template'    #   ctl_options_template_toggle_path
  get '/ctl/options/template/edit' => 'apps/time_learning#edit_template'    #   ctl_options_template_edit_path
  get '/ctl/options/template/destroy' => 'apps/time_learning#destroy_template'    #   ctl_options_template_destroy_path
  get '/ctl/options/template/show' => 'apps/time_learning#show_template'    #   ctl_options_template_show_path
  get '/ctl/options/template/copy' => 'apps/time_learning#copy_template'    #   ctl_options_template_copy_path
  get '/ctl/options/filters' => 'apps/time_learning#manage_filters'    #  ctl_options_filters_path
  get '/ctl/options/template' => 'apps/time_learning#manage_template'  #  ctl_options_template_url
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
  get '/elt/case/add' => 'apps/learning_time#start_case'    # elt_case_add_path
  post '/elt/case/add' => 'apps/learning_time#start_case'
  get '/elt/case/show' => 'apps/learning_time#show_case'   # elt_case_show_path
  get '/elt/case/finalize' => 'apps/learning_time#toggle_finalize_case'
  get '/elt/map/evidence/show' => 'apps/learning_time#show_evidence_map'    # elt_map_evidence_show
  get '/elt/map/activity/show' => 'apps/learning_time#show_activity_map'    # elt_map_activity_show
  get '/elt/case/header/update' => 'apps/learning_time#assign_case_header'
  post '/elt/case/update' => 'apps/learning_time#update_case_b'
  get '/elt/case/comments' => 'apps/learning_time#list_case_comments'
  get '/elt/case/support/findings' => 'apps/learning_time_standards#supporting_findings'   # elt_case_support_findings
  get '/elt/case/evidence/copy' => 'apps/learning_time#case_evidence_copy'   # elt_case_evidence_copy_path
  get '/elt/case/evidence/add' => 'apps/learning_time#case_evidence_add'   # elt_case_evidence_add
  post '/elt/case/evidence/add' => 'apps/learning_time#case_evidence_add'   # elt_case_evidence_add
  get '/elt/case/evidence/change' => 'apps/learning_time#case_evidence_change'   # elt_case_evidence_change
  get '/elt/case/evidence/destroy' => 'apps/learning_time#case_evidence_destroy'   # elt_case_evidence_destroy_path
  get '/elt/case/evidence/rl/add' => 'apps/learning_time#case_evidence_rl_add'   # elt_case_evidence_rl_add_path
  get '/elt/case/evidence/show' => 'apps/learning_time#manage_case_evidence'   # elt_case_evidence_show_path
  get '/elt/config/standards' => 'apps/learning_time_standards#index'
  get '/elt/config/standard/edit' => 'apps/learning_time_standards#maintain_standard'
  post '/elt/config/standard/edit' => 'apps/learning_time_standards#maintain_standard' # elt_config_standard_edit
  get '/elt/config/standard/destroy' => 'apps/learning_time_standards#destroy'
  get '/elt/config/standard/activate' => 'apps/learning_time_standards#toggle_active'
  get '/elt/config/standard/public' => 'apps/learning_time_standards#toggle_public'
  get '/elt/config/standard/update' => 'apps/learning_time_standards#update'
  get '/elt/config/standard/element/add' => 'apps/learning_time_standards#new_element'
  post '/elt/config/standard/element/add' => 'apps/learning_time_standards#create_element'
  get '/elt/config/standard/element/activate' => 'apps/learning_time_standards#toggle_element_active'
  get '/elt/config/standard/element/edit' => 'apps/learning_time_standards#edit_element'
  post '/elt/config/standard/element/update' => 'apps/learning_time_standards#update_element'
  get '/elt/config/standard/element/indicator/edit' => 'apps/learning_time_standards#edit_indicator'
  get '/elt/config/standard/element/indicator/activate' => 'apps/learning_time_standards#toggle_indicator_active'
  get '/elt/config/standard/element/indicator/destroy' => 'apps/learning_time_standards#destroy_indicator'
  get '/elt/config/standard/element/indicator/add' => 'apps/learning_time_standards#new_indicator'
  post '/elt/config/standard/element/indicator/add' => 'apps/learning_time_standards#create_indicator'
  post '/elt/config/standard/element/indicator/update' => 'apps/learning_time_standards#update_indicator'
  get '/elt/config/standard/element/indicator/desc/update' => 'apps/learning_time_standards#update_descriptor'
  get '/elt/config/standard/element/indicator/desc/destroy' => 'apps/learning_time_standards#destroy_descriptor'
  get '/elt/config/cycles' => 'apps/learning_time#manage_cycles'
  get '/elt/config/cycle/edit' => 'apps/learning_time#maintain_cycle'
  post '/elt/config/cycle/edit' => 'apps/learning_time#maintain_cycle'
  get '/elt/config/cycle/activate' => 'apps/learning_time#toggle_active_cycle'
  get '/elt/config/cycle/school/assign' => 'apps/learning_time#assign_school_cycle'
  get '/elt/config/cycle/destroy' => 'apps/learning_time#destroy_cycle'
  get '/elt/config/cycle/activity/assign' => 'apps/learning_time#assign_cycle_activity'
  get '/elt/config/cycle/element/assign' => 'apps/learning_time#assign_cycle_element'
  get '/elt/config/activities' => 'apps/learning_time#manage_activities'
  get '/elt/config/activity/edit' => 'apps/learning_time#maintain_activity'
  post '/elt/config/activity/edit' => 'apps/learning_time#maintain_activity'
  get '/elt/config/activity/rubric/activate' => 'apps/learning_time#toggle_rubric'
  get '/elt/config/activity/rubric/share' => 'apps/learning_time#share_rubric'
  get '/elt/config/activity/rubric/delete' => 'apps/learning_time#delete_rubric'
  get '/elt/config/rubric/activate' => 'apps/learning_time#toggle_rubric'  #config_rubric_activate
  get '/elt/config/activity/activate' => 'apps/learning_time#toggle_active_activity'
  get '/elt/config/activity/master' => 'apps/learning_time#toggle_master_activity'
  get '/elt/config/indicators' => 'apps/learning_time#manage_indicators'   # elt_config_indicators_path
  get '/elt/config/indicator/activity/source' => 'apps/learning_time#select_source_activity'   # elt_config_indicator_activity_source
  get '/elt/config/indicator/activity/target' => 'apps/learning_time#select_activity'  # elt_config_indicator_activity_target
  get '/elt/config/indicator/copy' => 'apps/learning_time#copy_activity_indicators'  # elt_config_indicator_copy
  get '/elt/config/indicator/element/select' => 'apps/learning_time#select_element'  # elt_config_indicator_element_select
  get '/elt/config/indicator/edit' => 'apps/learning_time#maintain_indicator'  #   elt_config_indicator_edit_path
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
  get '/elt/activity/cycle/school/cases' => 'apps/learning_time#show_school_cycle_activity_cases' # elt_activity_cycle_school_cases_path
  get '/elt/activity/cycle/school/activities' => 'apps/learning_time#list_school_cycle_activities' #elt_activity_cycle_school_activities
  get '/elt/survey/start' => 'apps/learning_time#send_school_cycle_survey'
  get '/elt/survey/stop' => 'apps/learning_time#stop_school_cycle_surveys'
  get '/elt/community/filters' => 'apps/learning_time#select_kb_filters'   # elt_community_filters
  get '/elt/community/indicator/rubric' => 'apps/learning_time#case_indicators_element_rubric'   # elt_community_indicator_rubric
  get '/elt/community/case/rubric' => 'apps/learning_time#case_element_rubric'   # elt_community_case_rubric
  get '/elt/report' => 'apps/app_report#elt_school_diag'   # elt_report_path
  get '/elt/report/school/plan' => 'apps/app_report#elt_school_plan'
  get '/elt/report/school/cycle/plan' => 'apps/learning_time#school_cycle_plan' # elt_report_school_cycle_plan_url
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


  # APP PD

  get '/pd/cycle/close' => 'apps/staff_develop#close_cycle'  #  pd_cycle_close_path
  post '/pd/cycle/close' => 'apps/staff_develop#close_cycle'  #  pd_cycle_close_path

  # PDF
  get '/pdf/elt/case' => 'apps/app_pdf#elt_case'
  #=======================================================

end
