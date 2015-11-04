class Admin::OurCausesController < Admin::ApplicationController
  layout false
#  protect_from_forgery :except => "index"
  
  before_filter :find_topic, :only => [:edit, :update, :update_featured_topic, :add_content, :remove_content, :destroy]
  
  def index
    if request.post?
      if params[:organization]
        flash[:error] = @current_organization.errors.full_messages.to_sentence unless @current_organization.update_attributes params[:organization]
        respond_to do |format|
          format.js do
            responds_to_parent do
              render :update do |page|
                page.replace_html "affiliate_information_panel", :partial => 'affiliate_information', :object => @current_organization
              end
            end          
          end
        end
      else
        params[:sections].each do |key, value|
          page_section = @current_organization.page_sections.find_or_create_by_page_and_section("index", key)
          page_section.update_attributes :body => value, :author => @current_user
        end
      end
      
      @fundraising_campaigns = @current_organization.fundraising_campaigns
    end
    
    @active_topics = @current_organization.topics.active
    @pending_topics = @current_organization.topics.pending
    @closed_topics = @current_organization.topics.closed
  end
  
  def form_submit
    params[:sections].each do |key, value|
      page_section = @current_organization.page_sections.find_or_create_by_page_and_section("index", key)
      page_section.update_attributes :body => page_section.unite_body(value), :author => @current_user
    end if params[:sections].present?
    responds_to_parent do 
      render :update do |page|
        page.alert("Update succeed")
      end
    end
  end
  
  def preview_image
    file_path = Import.image_save(params[:sections][:call_to_action][:image]) 
    responds_to_parent do 
      render :update do |page|
        if file_path.blank?
          page.alert("Error file type")
        else
          page.replace_html "preview_image_div" , "<img src = '#{file_path}' /><input type='hidden' name='sections[call_to_action][image_path]' id='image_path' value='#{file_path}'>"
        end
      end
    end
  end
  
  def new
    @topic = @current_organization.topics.new     
    @topic.discussion = Discussion.new
    initialize_discussion_setting_values if @topic.setting_values.empty?
    @contents = []
  end
  
  def create
    if request.post?
      params[:topic][:publish_end_date] = nil if params[:no_publish_end_date] == "1"
      @topic = @current_organization.topics.new(params[:topic])
      @topic.user = @current_user
      @topic.discussion.organization = @current_organization
      @topic.discussion.user = @current_user
      if @topic.save
        flash[:notice] = "Topic successfully created"
        redirect_to :action => :index, :organization_id => @current_organization
      else
        flash[:error] = @topic.errors.full_messages.to_sentence
        render :action => :new
      end
    end    
  end
  
  def edit
    initialize_discussion_setting_values if @topic.setting_values.empty?
    @contents = @topic.contents
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = e.message
    redirect_to :action => :index, :organization_id => @current_organization
  end
  
  def update  
    params[:topic][:publish_end_date] = nil if params[:no_publish_end_date] == "1"
    
    if @topic.update_attributes(params[:topic])
      redirect_to :action => :index, :organization_id => @current_organization
    else
      render :action => :edit
    end
  end
  
  def update_content_search_settings
    @current_organization.update_search_setting_value_named("Content Search Filter", params["Content Search Filter"])
  end
  
  def update_featured_topic
    @current_organization.update_attributes(:featured_topic => @topic) unless @current_organization.featured_topic == @topic
    render :text => ""
  end
  
  def update_trusted_topic_sources
    trusted_topic_source_organizations = []
    params[:trusted_topic_source_ids].each do |organization_id|
      organization = Organization.find_by_public_id(organization_id)
      trusted_topic_source_organizations << organization
      @current_organization.trusted_topic_sources.create(:source => organization) unless @current_organization.trusted_topic_sources.find_by_source_id(organization.id)
    end
    @current_organization.trusted_topic_sources.each do |tts|
      @current_organization.trusted_topic_sources.delete(tts) unless trusted_topic_source_organizations.include?(tts.source)
    end
    render :text => ""
  end
  
  # to be added later
  def update_discussion_inclusion_settings
  end

  def set_stream_organization
    if request.xhr?
        render :text => "Streaming has been disabled."
    end   
  end

  def add_content
    content_public_ids = @topic.contents.collect{|c| c.public_id}
    params[:content_ids].each{|id| params[:content_ids].delete(id) if content_public_ids.include? id }
    unless params[:content_ids].empty?
      @topic.contents << params[:content_ids].collect{|id| Content.find_by_public_id(id)}
    end
    respond_to do |wants|
      wants.html {render :template => "/admin/topics/add_or_remove_content.html.erb"} 
    end  
  end
  
  def remove_content
    @topic.contents.delete Content.find_by_public_id(params[:content_id])
    respond_to do |wants|
      wants.html {render :template => "/admin/topics/add_or_remove_content.html.erb"} 
    end  
  end
  
  def sort_content
    if params[:id] && params[:content_ids]
      @topic = @current_organization.topics.find_by_public_id params[:id]
    end
    respond_to do |wants|
      wants.html {render :template => "/admin/topics/contents.html.erb"} 
    end 
  end
  
  def destroy
    @topic.destroy if @topic.can_be_deleted?
    redirect_to :action => :index, :organization_id => @current_organization
  end
  
  protected
  
  def initialize_discussion_setting_values
    @topic.setting_values << SettingValue.new(:setting => Setting.find_by_name('Permission To Contribute'), :value => 'All')
    @topic.setting_values << SettingValue.new(:setting => Setting.find_by_name('Moderation'), :value => 'None')
  end
  
  def find_topic
    @topic = @current_organization.topics.find_by_public_id params[:id]
  end
end
