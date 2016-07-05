class Site::ApplicationController < ApplicationController     

  helper :all # include all helpers, all the time
  layout "site"


  
  protected

  
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
