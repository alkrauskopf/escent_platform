class Master::TopicsController < Master::ApplicationController
  
  before_filter :current_topic, :only => [:suspend, :unsuspend, :discussion_abuses, :discussion_abuse_details, :remove_abuse]
  
  def topic_abuses
    @topics = Topic.find(:all).paginate :per_page => 10, :page => params[:page]
  end
  
  def discussion_abuses
  end
  
  
  def suspend
    Discussion.find(params[:discussion_id]).suspend!(:user => @current_user)    
    
    current_topic
    
    redirect_to :action => :discussion_abuses, :topic_id => @topic, :page => params[:page]   
  end
  
  def unsuspend
    Discussion.find(params[:discussion_id]).unsuspend!(:user => @current_user)
    
    current_topic
    
    redirect_to :action => :discussion_abuses, :topic_id => @topic, :page => params[:page]   
  end
  
  def discussion_abuse_details
    @abuses =   Discussion.find(params[:discussion_id]).reported_abuses
    @abuses.paginate :per_page => 10, :page => params[:page]
  end
  
  def remove_abuse
    abuse = ReportedAbuse.find(params[:abuse_id])
    abuse.destroy
    redirect_to :action => :discussion_abuse_details, :discussion_id => params[:discussion_id], :topic_id => @topic, :page => params[:page]       
  end
  
  protected
  
  def current_topic
    @topic = Topic.find_by_public_id(params[:topic_id])
    @discussions = @topic.discussions.paginate :per_page => 10, :page => params[:page]    
  end
end
