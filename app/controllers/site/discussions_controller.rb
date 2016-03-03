class Site::DiscussionsController < Site::ApplicationController
  layout "site"    
  
  protect_from_forgery :except => [:add_reply, :delete_reply, :report_abuse, :share_content, :share_discussion]
  before_filter :find_featured_topic, :only => [:show, :add_comment]
  
  def show
    @discussion = @current_organization.discussions.find_by_public_id params[:id]
    @discussions = @current_organization.discussions.paginate(:page => params[:page], :conditions => ["parent_id = ?", @discussion.id], :order => "created_at ASC")                  
    respond_to do |format|
      format.js { render :partial => "discussions"}  
    end
  end                                                               
  
  def add_comment
    @topic = Topic.find_by_public_id params[:topic_id] rescue nil
    if @topic
      @topic.add_comment(params[:new_discussion].merge(:user => @current_user)) if params[:new_discussion]
      @discussions = @topic.discussions.active.parent_id_blank(:order_by =>  "created_at #{params[:parent_id] ? 'ASC' : 'DESC'}")            
    
      if @topic.should_notify
        classroom = @topic.classroom
        discussion = params[:new_discussion]
        classroom.leaders.each do |cl|
        Notifier.deliver_topic_comment(:user => cl,:current_user=>@current_user,:current_organization => @current_organization, :topic => @topic, :new_discussion => discussion, :fsn_host => request.host_with_port)
        end
      end
    end

    # @discussions = @current_topic.discussions.active.paginate(:page => params[:page], :conditions => ["parent_id IS NULL"], :order => "created_at #{params[:parent_id] ? 'ASC' : 'DESC'}")

    render :partial => "discussions", :locals=>{:topic => @topic, :viewable => @current_user ? @topic.classroom.viewable_by?(@current_user) : nil}
  end
  
  def add_comment_for_resource
    @content = Content.find_by_public_id params[:content_id] rescue nil
    @content.add_comment(params[:new_discussion].merge(:user => @current_user)) if params[:new_discussion]
    @discussions = @content.discussions.active.parent_id_blank(:order_by =>  "created_at #{params[:parent_id] ? 'ASC' : 'DESC'}")
    owner = User.find_by_id(@content.user_id)
    discussion = params[:new_discussion]
    if owner
          Notifier.deliver_resource_comment(:user => owner,:current_user=>@current_user,:content => @content, :new_discussion => discussion, :fsn_host => request.host_with_port)
    end
    render :partial => "discussions_for_resource"    
  end
 
  def delete_resource_comment
    
    @content = Content.find_by_public_id params[:content_id] rescue nil
    discussion = @content.discussions.active.find_by_public_id params[:id]
    if @current_user.has_authority?(@classroom, AuthorizationLevel.app_teacher(CoopApp.classroom))
      discussion.make_as_delete(@current_user.id)
    end
      render :text => "** This Comment Has Been Removed **" and return
  end
  
  
  def add_reply
    if params[:comment].blank?
      render :text => "Can't save your reply because the comment is blank." 
    else
      @discussion = @current_organization.discussions.active.find_by_public_id params[:id]
      @discussion.discussionable.add_comment(:comment => params[:comment], :parent_id => @discussion.public_id, :user => @current_user)
      render :partial => "discussion_reply", :collection => @discussion.children, :locals=>{:entity => @discussion.discussionable}
    end
  end
  
  def delete_reply
    discussion = @current_organization.discussions.active.find_by_public_id params[:id]
#    if @current_user.has_authority?(@classroom, "leader")
      discussion.make_as_delete(@current_user.id)
#    end
      render :text => "** This Comment Has Been Removed **" and return

  end
  
  def reply_or_login
    render :partial => "/shared/reply_or_login"
  end
  
  def report_abuse
    unless params[:abuse].blank?
      @discussion = @current_organization.discussions.active.find_by_public_id params[:id]
      @discussion.report_abuse(:abuse => params[:abuse], :user => @current_user)
    end
    render :text => "Reported as #{params[:abuse]}." 
  end
  
  def share_content
    if request.xhr?
      @content = Content.find_by_public_id params[:id]
      sender_emails = params[:email_archive][:sender_email].split(/, */)
      sender_emails.each do |sender_email|
        @current_organization.metrics << Metric.new(2 , @current_user.id)
        Notifier.deliver_share_content(:current_organization => @current_organization, :content => @content, :user => @current_user, :sender_email => sender_email, :message => params[:email_archive][:plain_body], :fsn_host => request.host_with_port)
      end
      render :text => ""
    end
  end

  def share_pilot_feedback2
    if request.xhr?
     @user = User.find_by_public_id params[:id]
     @current_organization = Organization.find_by_public_id params[:organization_id]
     sender_emails = params[:email_archive][:sender_email].split(/, */)
     sender_emails.each do |sender_email|
       @current_organization.metrics << Metric.new(2 , @user.id)
       Notifier.deliver_share_pilot_feedback(:current_organization => @current_organization, :user => @user, :sender_email => sender_email, :message => params[:email_archive][:plain_body], :fsn_host => request.host_with_port)
     end
     render :text => ""
    end
  end  
  
  def share_pilot_feedback
    if request.xhr?
     @user = User.find_by_public_id params[:id]
     sender_emails = params[:email_archive][:sender_email].split(/, */)
     sender_emails.each do |sender_email|
       @current_organization.metrics << Metric.new(2 , @user.id)
       Notifier.deliver_share_pilot_feedback(:current_organization => @current_organization, :user => @user, :sender_email => sender_email, :message => params[:email_archive][:plain_body], :fsn_host => request.host_with_port)
     end
     render :text => ""
    end
  end
  
  def share_discussion
    if request.xhr?
      @topic = Topic.find_by_public_id params[:id]
      sender_emails = params[:email_archive][:sender_email].split(/, */)
      sender_emails.each do |sender_email|
        @current_organization.metrics << Metric.new(1 , @current_user.id)
        Notifier.deliver_share_discussion(:current_organization => @current_organization, :topic => @topic, :user => @current_user, :sender_email => sender_email, :message => params[:email_archive][:plain_body], :fsn_host => request.host_with_port)
      end
      render :text => ""
    end
  end  
end
        
        
        
        
        
        
        
        
        
        
        