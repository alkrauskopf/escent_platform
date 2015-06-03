class Admin::BlogsController < Admin::ApplicationController
  before_filter :load_data
  after_filter :load_data  
  # layout false


  def new
    render :update do |page|
      page.replace_html "create_blog_div" , :partial => "new"
    end
  end
  
  def create
    @blog.creator_id = @current_user.id
    render :update do |page|
      if @current_organization.blogs << @blog
        page.insert_html :after , "insert_blog" , :partial => "/admin/blogs/show"
        page.replace_html "create_blog_div" , ""
      else
        page.replace_html "blog_error_message" , error_messages_for(:blog)
      end
    end
  end
  
  def edit
    find_or_create_blog_panel  
    people_not_in_panle
    render :update do |page|
      page.replace_html "create_blog_div" , :partial => "edit"
    end
  end
  
  def update
    render :update do |page|
      if @blog.update_attributes(params[:blog])
        page.replace "blog_#{@blog.public_id}" , :partial => "/admin/blogs/show"
        page.replace_html "create_blog_div" , ""
      else
        page.replace_html "blog_error_message" , error_messages_for(:blog)
      end
    end
  end
  
  def destroy
    @blog.destroy
    render :update do |page|
      page.remove "blog_#{@blog.public_id}" if @blog.public_id.present?
      page.replace_html "create_group_div" , ""
    end
  end  
  
  def add_user_to_panel

    add_or_remove_user(:add)
    people_not_in_panle
    render :partial => "add_to_panel", :layout => false
  end
  
  def remove_user_from_panel

    add_or_remove_user(:remove)
    people_not_in_panle
    render :partial => "add_to_panel", :layout => false
  end
  
  def set_feature
    if @blog.feature
      @blog.update_attribute("feature", false)
     else
       @current_organization.clear_featured_blog
       @blog.update_attribute("feature", true)
    end
#    @blog.set_as_feature
#    render :text => "Set Feature Successful."
    render :partial => "blog_list"
  end
  
  private
  
  def load_data
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil || Blog.new(params[:blog])
  end
  
  def find_or_create_blog_panel
    @blog_panel = @blog.users || BlogUser.create(:blog_id => @blog.id, :user_id => @current_user.id)
  end
  
  def people_not_in_panle
#    @people = (User.find :all, :include => [:authorizations, :roles], :conditions => ["(authorizations.scope_id = ? AND authorizations.scope_type = ?) OR (roles.id IN (?))", @current_organization, "Organization", @current_organization.roles.collect{|r| r.id}])
    @people = @current_organization.org_followers - @blog.panelists
  end
  
  def add_or_remove_user(method)
    user = User.find(params[:user_id])        
    case method
    when :add
      @blog.users << user      
    when :remove
      @blog.users.delete user      
    end
  end
end
