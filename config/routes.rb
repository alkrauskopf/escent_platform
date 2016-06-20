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

  # CORE Offering  (Classroom)
    get '/offering/view' => 'site/site#static_classroom'
    get '/offering/setup' => 'apps/classroom#setup_classroom'
    get '/offering/lu/setup' => 'apps/classroom#setup_classroom_lu'
    get '/offering/toggle_favorite' => 'apps/classroom#toggle_favorite_classroom'

  # CORE Resource (Content)
    get '/resource/view' => 'site/site#static_resource'
    get '/resource/new' => 'site/contents#submit_resource'
    get '/resource/edit' => 'site/contents#index'

  # CORE Blog
    get '/app_blog/view' => 'apps/app_blog#show_app_blog'

  # CORE Organization
    get '/organization/view' => 'site/site#static_organization'

  # CORE Search
    get '/search' => 'site/site#search'

  # CORE Admin
    post '/admin' => 'admin/application#index'
    get '/admin/notify' => 'admin/our_organization#toggle_notification'
    post '/admin/org_edit' => 'admin/our_organization#update_profile'
    get '/admin/family/authorizations' => 'admin/our_family#new_user_authorization'
    get '/admin/family/show' => 'admin/our_family#view_auth_members'
    get '/admin/family/user_authorizations' => 'admin/our_family#authorize_user'
    get '/admin/family/authorize' => 'admin/our_family#toggle_authorization'
    get '/admin/family/owner_authorize' => 'admin/our_family#toggle_app_authorization'

  # CORE Master
    get '/master/index' => 'master/application#index'
    get '/master/users/show' => 'master/users#index'
    get '/master/organizations/show' => 'master/organizations#index'
    get '/master/organizations/app_owners' => 'master/organizations#ownership'
    get '/master/organizations/app_usage' => 'master/organizations#app_useability'
    get '/master/organizations/new' => 'master/organizations#new'
    get '/master/apps/new' => 'master/coop_apps#edit_app'
    get '/master/apps/view' => 'master/coop_apps#index'

  # APPS Shared
    get '/my_survey/view' => 'apps/shared#my_surveys'

  #=======================================================

  # Victor add next two line just for test
  map.connect '/static_organization/:organization_id/:id', :controller => 'site/site', :action => 'static_organization', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect '/static_resource/:organization_id/:id', :controller => 'site/site', :action => 'static_resource', :requirements => {:organization_id => /[a-f\d]{16}/}
  map.connect '/static_classroom/:organization_id/:id', :controller => 'site/site', :action => 'static_classroom', :requirements => {:organization_id => /[a-f\d]{16}/}

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
  map.connect 'NCTL', :controller => 'site/site', :action => 'static_organization', :organization_id => 'e9826fddf20737fd'

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
