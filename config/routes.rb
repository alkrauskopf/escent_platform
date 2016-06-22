EscentPartners::Application.routes.draw do |map|

  # You can have the root of your site routed with "root"
 # root 'fsn#index'

  # <%= link_to 'Edit Profile', user_edit_path %>
  #     <a href="/profile/edit">Edit Profile</a>

  # <%= link_to 'Edit Profile', profile_edit_url %>
  #     <a href="http://localhost:3000/profile/edit">Edit Profile</a>
  #   *** USE THIS IN ANY MAILERS ***

  #  CORE Main Page
    get '/ep' => 'fsn#index'
    get '/ep/blog/view' => 'fsn#select_blog'

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
    get '/user/register' => 'users#register'
    get '/user/forgot_password' => 'users#forgot_password'
    post '/user/forgot_password' => 'users#forgot_password'

  # CORE Resource (Content)
    get '/resource/view' => 'site/site#static_resource'
    get '/resource/new' => 'site/contents#submit_resource'
    put '/resource/new' => 'site/contents#submit_resource'
    get '/resource/show' => 'site/contents#index'
    get '/resource/edit' => 'site/contents#edit_resource'
    get '/resource/subjects' => 'site/contents#select_subject_areas'
    get '/resource/types' => 'site/contents#select_resource_types'
    get '/resource/share' => 'site/discussions#share_content'

  # CORE Organization
    get '/organization/view' => 'site/site#static_organization', :requirements => {:organization_id => /[a-f\d]{16}/}
    get '/organization/view/app' => 'site/site#summarize_org_app'
    get '/organization/view/offering' => 'site/site#summarize_org_subject_offerings'
    get '/organization/view/resources' => 'site/site#summarize_org_resources'

  # CORE Search
    get '/search' => 'site/site#search'

  # CORE Admin
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
    get '/ep/tos' => 'fsn#terms'
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
    get '/discussion/reply' => 'site/discussions#add_reply'
    get '/discussion/reply/delete' => 'site/discussions#delete_reply'
    post '/discussion/comment/new' => 'site/discussions#add_comment'
    get '/discussion/report/abuse' => 'site/discussions#report_abuse'

  # Main Application Route Paths
    get '/' + CoopApp.classroom.app_link[2] => CoopApp.classroom.app_link[0] + '#' + CoopApp.classroom.app_link[1]
    get '/' + CoopApp.ifa.app_link[2] => CoopApp.ifa.app_link[0] + '#' + CoopApp.ifa.app_link[1]
    get '/' + CoopApp.ctl.app_link[2] => CoopApp.ctl.app_link[0] + '#' + CoopApp.ctl.app_link[1]
    get '/' + CoopApp.pd.app_link[2] => CoopApp.pd.app_link[0] + '#' + CoopApp.pd.app_link[1]
    get '/' + CoopApp.ita.app_link[2] => CoopApp.ita.app_link[0] + '#' + CoopApp.ita.app_link[1]
    get '/' + CoopApp.stat.app_link[2] => CoopApp.stat.app_link[0] + '#' + CoopApp.stat.app_link[1]
    get '/' + CoopApp.cm.app_link[2] => CoopApp.cm.app_link[0] + '#' + CoopApp.cm.app_link[1]
    get '/' + CoopApp.elt.app_link[2] => CoopApp.elt.app_link[0] + '#' + CoopApp.elt.app_link[1]
    get '/' + CoopApp.blog.app_link[2] => CoopApp.blog.app_link[0] + '#' + CoopApp.blog.app_link[1]

  # APPS Shared
    get '/my_survey/view' => 'apps/shared#my_surveys'
    get '/app/owner/maintenance' => 'apps/owner_maintenance#index'

  # APP Offering  (Classroom)
    get '/offering/view' => 'site/site#static_classroom'
    get '/offering/setup' => 'apps/classroom#setup_classroom'
    get '/offering/lu/setup' => 'apps/classroom#setup_classroom_lu'
    get '/offering/toggle_favorite' => 'apps/classroom#toggle_favorite_classroom'
    get '/offering/unjoin' => 'apps/classroom#self_unregister_student'
    get '/offering/register' => 'apps/classroom#register_classroom'
    get '/offering/homework' => 'site/site#submit_homework'
    get '/offering/lu/resources/featured' => 'site/site#featured_content'
    get '/offering/lu/resources/related' => 'site/site#related_content'
    get '/offering/lu/resources/show' => 'apps/classroom#show_lu_resources'

  # APP Blogs
    get '/app_blog/view' => 'apps/app_blog#show_app_blog'

  # APPS IFA
    get '/ifa/teacher/review' => 'apps/assessment#teacher_review'
    get '/ifa/assessment/take' => 'apps/assessment#take_assessment'
    get '/ifa/lu/standards/show' => 'apps/assessment#topic_standards_benchmarks'

  # APP CTL
    get '/ctl/session/show' => 'apps/time_learning#static_itl_session'

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
  map.connet '/site/prayer_pledges/register', :controller =>'site/prayer_pledges', :action =>'index'
# ALK
  map.connect  '/apps/assessment', :controller => 'apps/assessment'
  map.connect  '/apps/blogs', :controller => 'apps/blogs'
  map.connect  '/apps/app_blog', :controller => 'apps/app_blog'
  map.connect  '/apps/time_learning', :controller => 'apps/time_learning'
  map.connect  '/apps/school_time', :controller => 'apps/school_time'
  map.connect  '/apps/client_manager', :controller => 'apps/client_manager'
  map.connect  '/apps/learning_time', :controller => 'apps/learning_time'
  map.connect  '/apps/panel', :controller => 'apps/panel'
  map.connect  '/apps/classroom', :controller => 'apps/classroom'
  map.connect  '/apps/staff_develop', :controller => 'apps/staff_develop'
  map.connect  '/apps/shared', :controller => 'apps/shared'
  map.connect  '/site/blog_posts', :controller => 'site/blog_posts'
  map.connect  '/site/contents', :controller => 'site/contents'
  map.connect '/site/:organization_id', :controller => 'site/site', :action => 'index', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect  '/site/site', :controller => 'fsn', :action => 'index'
  map.connect '/site/', :controller => 'site/site', :action => 'index'

  map.connect '/admin/', :controller => 'admin/application', :action => 'index'
  map.connect '/admin/application/index/:organization_id',  :controller => 'admin/application', :action => 'index', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect '/admin/:organization_id',  :controller => 'admin/application', :action => 'index', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect '/admin/:controller/:action/:organization_id', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect '/admin/:controller/:action/:organization_id/:id', :requirements => {:organization_id => /[a-f\d]{16}/}

  map.connect '/master/', :controller => 'master/application', :action => 'index'

  map.connect ':controller/:action/:organization_id', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect ':controller/:action/:organization_id/:id', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect ':controller/:action/:organization_id.:format', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect ':id/blog/:year/:month/:day/:title', :controller => 'site/blog_posts', :action => 'show', :id => :id
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
  map.simple_captcha '/simple_captcha/:action', :controller => 'simple_captcha'
end
