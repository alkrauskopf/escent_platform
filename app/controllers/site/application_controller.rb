class Site::ApplicationController < ApplicationController     

  helper :all # include all helpers, all the time
  layout "site"
#  before_filter :filter_not_active
  before_filter :current_organization
  before_filter :current_user
  before_filter :current_application
  before_filter :core_enabled_for_current_org?
 # before_filter :current_app_enabled_for_current_org?
  
  protected


  def filter_not_active
    @organization = Organization.find_by_public_id(params[:organization_id])
    if @organization.present? && @organization.actived?
      return true
    else
      return redirect_to(:controller => "/organizations" , :action => "not_actived")
    end
  end
  
  # Victor rewrite find_featured_topic method for tcpj
  def find_featured_topic
    @current_classroom ||= (Classroom.find_by_public_id(params[:id]) rescue @current_organization.classrooms.active.first)
    unless @current_classroom
      @current_classroom = Classroom.all.first
    end
    if !params[:topic_id].blank? 
      @current_topic = Topic.find_by_public_id params[:topic_id]
      @return_topic = @current_topic
    elsif @current_classroom && @current_classroom.featured_topic
#    elsif @current_classroom.featured_topic && @current_classroom.featured_topic.active?
      @current_topic = @current_classroom.featured_topic
      @return_topic = []
    else
      @current_topic = @current_classroom.topics.active.first rescue nil
      @return_topic = []
    end
    if (@current_topic && @current_topic.featured_content)
      @content = Content.find(@current_topic.featured_content) rescue nil
    end
   if (@current_topic && @current_topic.contents.size>0)
     @related_content = @content ? @current_topic.contents.select{|r| r != @content} : @current_topic.contents
   else
   @related_content = []
   end
#    @content = (@current_topic && @current_topic.featured_content) ? Content.find(@current_topic.featured_content) : nil
#    @related_content = @current_topic ? @current_topic.contents[1,@current_topic.contents.size] : []
 #   @related_content = []
#    if @current_topic
#      then resource_ids = @current_topic.topic_contents.sort{|a,b|a.display_position <=> b.display_position}
#      else resource_ids = []
#    end
 #   @related_content = []
 #   resource_ids.each do |r|
 #     unless r.content == @content
 #       @related_content<<r.content
#      end
#    end
#
# If there is only 1 related_content and No Featured Content, Treat the Related as Featured.
#  
  if @content.nil? && @related_content.size == 1
    then @content = @related_content.first
    @related_content = []
    end
#    @related_content = @current_topic ? @current_topic.contents.active - [@content] : []
    @other_active_topics = @current_classroom ? @current_classroom.topics.active.collect{|t| t} - [@current_classroom.featured_topic || @current_classroom.topics.active.first] : []
  end
  
end
