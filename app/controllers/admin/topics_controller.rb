class Admin::TopicsController < Admin::ApplicationController
  require 'yaml'
  layout "admin/classrooms/layout"
  
  before_filter :find_topic, :only => [:edit, :update, :update_featured_topic, :add_content,:destroy, :reported_abuses, :view_discussion_abuses, :remove_discussion]
  before_filter :clear_notification
  
  def clear_notification
    flash[:notice] = nil
    flash[:error] = nil
  end
  def index
    @classroom = Classroom.find(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @active_topics = @classroom.topics.estimated_active
#    @pending_topics = @classroom.topics
    @closed_topics = @classroom.topics.estimated_closed
    @all_topics = @active_topics + @closed_topics
  end
  
  def new
    @classroom = Classroom.find(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @topic = @classroom.topics.new
    initialize_discussion_setting_values if @topic.setting_values.empty?
    @contents = Content.active.paginate :per_page => 5, :page => params[:page]
    render :template => "/admin/content/search_results_for_topics.html.erb" if params[:page]
  end
  
  def create
    if request.post?
      @classroom = Classroom.find(params[:classroom_id])
      @current_organization = Organization.find_by_public_id(params[:organization_id])
      role_ids = params[:role_ids]
      params[:topic][:publish_ends_at] = nil if params[:no_publish_end_date] == "1"
      @topic = @classroom.topics.new(params[:topic])
      @topic.user = @current_user    
      if @topic.save
        @topic.update_discussion_setting_value_named('Permission To Contribute', role_ids.to_yaml) 
        flash[:notice] = "Topic successfully created"
        redirect_to :action => :index,:organization_id => @current_organization, :classroom_id => @classroom.id
      else
        flash[:error] = @topic.errors.full_messages.to_sentence
        render :action => :new
      end
    end    
  end
  
  def edit
    initialize_discussion_setting_values if @topic.setting_values.empty?
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    
    # currently can be a string "all" or an array of role_ids stored as YAML
    @who_may_contribute_value_settings = YAML::load(@topic.discussion_setting_value_named('Permission To Contribute'))

    @contents = Content.active.paginate :per_page => 15, :page => params[:page]
    render :template => "/admin/content/search_results_for_topics.html.erb" if params[:page]    
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to :action => :index,:organization_id => @current_organization, :classroom_id => @classroom.id
  end
 
  def assign_resource
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @current_organization = Organization.find_by_public_id(params[:organization_id])
    @topic = Topic.find_by_public_id(params[:topic_id])
    @avail_resources = (@current_user.favorite_resources + @topic.contents).uniq
    unless params[:content_id].nil?
     if params[:add_function]   
        added_content = Content.find_by_public_id(params[:content_id])
        @topic.contents << params[:content_id].collect{|id| Content.find_by_public_id(id)}
        flash[:notice] = "#{added_content.title} was added to #{@topic.title}"  
     else        
       removed_content = Content.find_by_public_id(params[:content_id])
       @topic.contents.delete removed_content
       if @topic.featured_content == removed_content.id
         @topic.featured_content = nil
         if @topic.save then    
          flash[:error] = "Notice: #{removed_content.title} was removed as a Featured Resource for #{@topic.title}. You should select another Featured Resource."
          else
          flash[:error] = "Error: #{removed_content.title} was NOT removed as a Featured Resource for #{@topic.title}." 
         end
        else
        flash[:notice] = "#{removed_content.title} was removed from #{@topic.title}."  
        end   
      end    
    end   
  end

  def update
    @current_organization = Organization.find_by_public_id(params[:organization_id]) 
    if @topic.update_attributes(params[:topic])
      redirect_to :action => :index,:organization_id => @current_organization, :classroom_id => @classroom.id
    else
      render :action => :edit
    end
  end
  
  def update_featured_topic
    @classroom.update_attributes(:featured_topic => @topic) unless @classroom.featured_topic == @topic
    render :text => ""
  end
  
  def add_content
    content_public_ids = @topic.contents.collect{|c| c.public_id}
    params[:content_ids].each{|id| params[:content_ids].delete(id) if content_public_ids.include? id }
    unless params[:content_ids].empty?
      @topic.contents << params[:content_ids].collect{|id| Content.find_by_public_id(id)}
    end
    render :template => "/admin/topics/add_or_remove_content"
  end
  

  
  def remove_content
    @classroom = Classroom.find_by_public_id(params[:classroom_id])
    @topic = Topic.find_by_public_id(params[:id])
    @topic.contents.delete Content.find_by_public_id(params[:content_id])
    respond_to do |wants|
      wants.html {render :template => "/admin/topics/add_or_remove_content"} 
    end  
  end
  
  def set_featured_content
    @topic = Topic.find_by_public_id(params[:id])
    @topic.featured_content = Content.find_by_public_id(params[:content_id]).id
    if @topic.save then
      flash[:notice] = "Updated topic featured content"
    else
      flash[:error] = "Error: Topic featured content could not be saved" 
    end
    render :partial => "notice"    
  end
  
  def sort_content
    if params[:id] && params[:content_ids]
      @topic = @current_organization.topics.find_by_public_id params[:id]
    end
    respond_to do |wants|
      wants.html {render :template => "/admin/topics/contents.html.erb"} 
    end 
  end
  
  def remove_discussion
    @topic.discussions.find(params[:discussion_id]).suspend!(:user => @current_user)
    render :template => "/admin/topics/reported_abuses"
  end
  
  def destroy
    @topic.destroy if @topic.can_be_deleted?
  redirect_to :action => :index,:organization_id => @current_organization, :classroom_id => @classroom.id
  end
  
  def reported_abuses
    @discussions = @topic.discussions.active
    @discussions.paginate :per_page => 10, :page => params[:page]
  end
  
  protected
  
  def initialize_discussion_setting_values
    @topic.setting_values << SettingValue.new(:setting => Setting.find_by_name('Permission To Contribute'), :value => 'All')
    @topic.setting_values << SettingValue.new(:setting => Setting.find_by_name('Moderation'), :value => 'None')
  end
  
  def find_topic
    @classroom = Classroom.find(params[:classroom_id])
    @topic = @classroom.topics.find_by_public_id params[:id]
  end
end
