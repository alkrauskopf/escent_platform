class Notifier < ActionMailer::Base
  
  def organization_registration(organization, user, organization_email, fsn_host, sent_at = Time.now)
    subject    'Escent Registration'
    recipients organization_email
    from       'organizationregistration@escentpartners.com'
    sent_on    sent_at    
    body      :organization => organization, :fsn_host => fsn_host
  end
  
  def forgot_password(user, password, sent_at = Time.now)
    subject    'Password Reset'
    recipients user.preferred_email
    from       'escentpartners.com'
    sent_on    sent_at
    body      :user => user, :password => password
  end
 
  def reset_password(params)
#
#  alternative to forgot_password
#
    @password = params[:password]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    @organization = @user.organization ? @user.organization : Organization.ep_default.first
    subject     'Escent Password Reset'
    recipients @user.preferred_email
    from       "escent_passwords<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :password => @current_user, :organization => @organization, :fsn_host => @fsn_host
  end
  
  def email_role(email, subject, message, sent_at = Time.now)
    subject    subject
    recipients email
    from       'escent_admin<noreply@escentpartners.com>'
    sent_on    sent_at
    body      message
  end
  
 def new_authorization(params)
    @auth_level = params[:authorization_level]
    @current_organization = params[:current_organization] 
    @current_user = params[:admin]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    subject     @current_organization.medium_name + " " + @auth_level.name.humanize + " Authorization"
    recipients @user.preferred_email
    from       "escent_authorization<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :current_user => @current_user, :current_organization => @current_organization, :auth =>@auth_level, :fsn_host => @fsn_host
  end
 
  def classroom_authorization(params)
    @auth_level = params[:authorization_level]
    @current_organization = params[:current_organization]
    @classroom = params[:classroom]
    @current_user = params[:admin]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    subject     @classroom.course_name + " " + @auth_level.name.humanize + " Authorization"
    recipients @user.preferred_email
    from       "escent_authorization<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :current_user => @current_user, :classroom => @classroom, :current_organization => @current_organization, :auth =>@auth_level, :fsn_host => @fsn_host
  end

  def survey_notification(params)
    @current_organization = params[:current_organization]
    @anon = params[:anon]? " <u>anonymous</u>": ""
    @current_user = params[:admin]
    @fsn_host = params[:fsn_host]
    @subject = params[:subject]
    @user = params[:user]
    subject   @subject  
    recipients @user.preferred_email
    from       "escent_survey<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :current_organization => @current_organization, :subject => @subject, :anon=> @anon, :current_user => @current_user, :fsn_host => @fsn_host
  end 

  def student_classroom_survey(params)
    @current_organization = params[:current_organization]
    @classroom = params[:classroom]
    @current_user = params[:admin]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    subject     @classroom.course_name + " Student Survey"
    recipients @user.preferred_email
    from       "escent_assessment<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :current_user => @current_user, :classroom => @classroom, :current_organization => @current_organization, :fsn_host => @fsn_host
  end  

  def student_itl_survey(params)
    @current_organization = params[:current_organization]
    @classroom = params[:classroom]
    @current_user = params[:admin]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    subject     @classroom.course_name + " Time & Learning Survey"
    recipients @user.preferred_email
    from       "escent_assessment<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :current_user => @current_user, :classroom => @classroom, :current_organization => @current_organization, :fsn_host => @fsn_host
  end 


  def assessment_submission(params)
    @current_organization = params[:current_organization]
    @classroom = params[:classroom]
    @current_user = params[:admin]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    @review_msg = params[:need_review] ? "Your Review Of The Assessment Is Required." : "Assessment Results Have Been Automatically Finalized."
    subject     @current_user.full_name + " Submitted An Assessment"
    recipients @user.preferred_email
    from       "escent_assessment<noreply@escentpartners.com>"
    sent_on  Time.now
    body    :user => @user, :current_user => @current_user, :classroom => @classroom, :current_organization => @current_organization, :fsn_host => @fsn_host
  end  
  
  def resource_comment(params)
    @user = params[:user]
    @current_user = params[:current_user]
    @content = params[:content]
    @resource_comment = params[:new_discussion][:comment]
    if @content.organization
      organization = @content.organization
    else
      organization = params[:current_organization]
    end
    if @current_user.home_organization
      user_org = @current_user.home_organization
    else
      user_org = organization
    end
    @fsn_host = params[:fsn_host]
    subject    "Resource Comment Notification"
    recipients @user.preferred_email
    from       'escent_resource_library<noreply@escentpartners.com>'
    sent_on    Time.now
    @body = {:user => @user, :current_user => @current_user, :content => @content, :new_discussion => @resource_comment, :organization => organization, :user_organization =>user_org, :fsn_host => @fsn_host}
  end

  def inform_blogger(params)
    @user = params[:user]
    @comment = params[:comment]
    @blog = params[:blog]
    @blog_post = params[:blog_post]
    @fsn_host = params[:fsn_host]
    subject    "Blog Comment Notification"
    recipients @blog_post.user.preferred_email
    from       'escent_blogging<noreply@escentpartners.com>'
    sent_on    Time.now
    @body = {:user => @user, :comment => @comment, :blog => @blog, :fsn_host => @fsn_host}
  end
  
  def topic_comment(params)
    @user = params[:user]
    @current_user = params[:current_user]
    @topic = params[:topic]
    @topic_comment = params[:new_discussion][:comment]
    @fsn_host = params[:fsn_host]
    current_organization = params[:current_organization]
    if @current_user.home_organization
      user_org = @current_user.home_organization
    else
      user_org = current_organization
    end
    subject    "Discussion Comment Notification"
    recipients @user.preferred_email
    from       'escent_classroom<noreply@escentpartners.com>'
    sent_on    Time.now
    @body = {:user => @user, :current_user => @current_user, :topic => @topic, :new_discussion => @topic_comment, :current_organization => current_organization, :user_organization =>user_org, :fsn_host => @fsn_host}
  end
  
  def resource_destroyed(params)
    @user = params[:user]
    @current_user = params[:current_user]
    @orig_title = params[:title]
    @content = params[:content]
    @fsn_host = params[:fsn_host]
    @current_organization = params[:current_organization]
    subject    "Classroom Resource Removal Notification"
    recipients @user.preferred_email
    from       'escent_resource_library<noreply@escentpartners.com>'
    sent_on    Time.now
    @body = {:user => @user, :current_user => @current_user, :title => @orig_title, :content => @content, :organization => @current_organization, :fsn_host => @fsn_host}
  end 

  def resource_updated(params)
    @user = params[:user]
    @current_user = params[:current_user]
    @orig_title = params[:title]
    @content = params[:content]
    @fsn_host = params[:fsn_host]
    @current_organization = params[:current_organization]
    subject    "Resource Update Notification"
    recipients @user.preferred_email
    from       'escent_resource_library<noreply@escentpartners.com>'
    sent_on    Time.now
    @body = {:user => @user, :current_user => @current_user, :title => @orig_title, :content => @content, :organization => @current_organization, :fsn_host => @fsn_host}
 end
 
  
  def share_discussion(params)
    user = params[:user]
    message = params[:message]
    from = params[:sender_email]
    topic = params[:topic]
    current_organization = params[:current_organization]
    @fsn_host = params[:fsn_host]
    
    @subject = "Invitation From #{user.first_name}"
    @recipients = from
    @from = 'escent_classroom<noreply@escentpartners.com>'
    @sent_on = Time.now
    @body = {:user => user, :message => message, :topic => topic, :current_organization => current_organization, :fsn_host => @fsn_host}
  end
  
  
  
  def user_registration (params)
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    current_organization = params[:current_organization]
    hidden = false
    subject    'Escent Registration'
    recipients @user.preferred_email
    from       'escent_registration<noreply@escentpartners.com>'
    sent_on    Time.now
    body      :user => @user, :fsn_host => @fsn_host, :current_organization => current_organization, :hidden => hidden
  end 

  def admin_notice(params)
    @user_organization = params[:user_organization]
    @admn = params[:admn]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    subject   'Escent Registration' 
    recipients @admn.preferred_email
    from       'escent_registration<noreply@escentpartners.com>'
    sent_on  Time.now
    body    :user => @user, :admn => @admn, :user_organization => @user_organization, :subject => @subject, :fsn_host => @fsn_host
  end 

  def observation_invite(params)
    @sender = params[:sender]
    @user = params[:user]
    @fsn_host = params[:fsn_host]
    if params[:arrange] == ""
      @arrange = @sender.full_name + " invites you to arrange a classroom observation."
    else
      @arrange = params[:arrange] == "1" ? (@sender.full_name + " would like to observe your classroom.") : ("Would you be willing to be a classroom observer of " + @sender.full_name + "?" )
    end
    @message = params[:message]
    subject   @sender.last_name + ' Classroom Observation Invitation' 
    recipients @user.preferred_email
    from       'escent_time_learning<noreply@escentpartners.com>'
    sent_on  Time.now
    body    :user => @user, :sender => @sender, :subject => @subject, :intro => @arrange, :text=> @message, :fsn_host => @fsn_host
  end 

  def itl_belt_change(params)
    @belt = ItlBeltRank.find_by_id(params[:rank]) rescue nil
    unless @belt.nil?
      @sender = params[:sender]
      @user = params[:user]
      @fsn_host = params[:fsn_host]
      @message = params[:message]
      subject   'Observation Proficieny Level Change' 
      recipients @user.preferred_email
      from       'escent_time_learning<noreply@escentpartners.com>'
      sent_on  Time.now
      body    :user => @user, :sender => @sender, :subject => @subject, :level => @belt.rank, :text=> @message, :fsn_host => @fsn_host
    end
  end 
    
  def successful_pledge_en(preferred_email, fsn_host, prayer_pledge , sent_at = Time.now)
    #    subject 'Odyssey Networks Prayer Pledge'
    subject "Pledge Confirmation"
    recipients preferred_email
    from       'odysseypledge@odysseynetworks.org'
    sent_on    sent_at
    body      :email_address => preferred_email, :fsn_host => fsn_host , :prayer_pledge => prayer_pledge
  end
  
  def successful_pledge_es(preferred_email, fsn_host, prayer_pledge , sent_at = Time.now)
    #    subject 'Odyssey Networks Prayer Pledge'
    subject "Pledge Confirmation"
    recipients preferred_email
    from       'odysseypledge@odysseynetworks.org'
    sent_on    sent_at
    body      :email_address => preferred_email, :fsn_host => fsn_host , :prayer_pledge => prayer_pledge
  end
  
    
  def organization_activate(email , fsn_host, sent_at = Time.now)
    subject    'Escent Registration'
    recipients email
    from       'Escent_Activate<noreply@escentpartners.com>'
    sent_on    sent_at    
    body       :fsn_host => fsn_host
  end
  
  def contact(sender_email, options = {})
    
    user = options[:user]
    subject      options[:subject]
    from         sender_email
    recipients   user.preferred_email
    sent_on      Time.now
    if options[:html_body].blank? || options[:html_body] == '<p>&nbsp;</p>'
      part(:content_type => "text/html", :body => render_message("contact.text.html.erb", :html_body => options[:html_body], :recipient_email => user.preferred_email)) unless options[:html_body].blank? || options[:html_body] == '<p>&nbsp;</p>'
    else
      part 'multipart/alternative' do |p|
        p.part :content_type => "text/html", :body => render_message("contact.text.html.erb", :html_body => options[:html_body], :recipient_email => user.preferred_email)
      end
  end
# Daniel - Removed for now because the attachment is not working. If you attach a file it only attaches part the file.  
#    if options[:attachment]
#      attachment :content_type => options[:attachment].content_type, :filename => options[:attachment].original_filename, :body => File.read(options[:attachment].path)
#    end
  end
  
  def share_content(params)
    user = params[:user]
    message = params[:message]
    from = params[:sender_email]
    content = params[:content]
    if content.organization
      organization = content.organization
    else
      organization = params[:current_organization]
    end
    @fsn_host = params[:fsn_host]
    @subject = "Invitation From #{user.first_name}"
    @recipients = from
    @from = 'escent_resource_share<noreply@escentpartners.com>'
    @sent_on = Time.now
    @body = {:user => user, :message => message, :content => content, :organization => organization, :fsn_host => @fsn_host}
  end
 
  def share_pilot_feedback(params)
    user = params[:user]
    message = params[:message]
    from = params[:sender_email]
    organization = params[:current_organization]
    @fsn_host = params[:fsn_host]
    @subject = "Pilot Feedback From #{user.full_name}"
    @recipients = from
    @from = 'escent_pilot_feedback<noreply@escentpartners.com>'
    @sent_on = Time.now
    @body = {:user => user, :message => message, :organization => organization, :fsn_host => @fsn_host}
  end
   
  def share_app_blog(params)
    @sender = params[:user_name]
    message = params[:message]    
    @blog = Blog.find_by_public_id(params[:blog_id]) rescue nil
    @fsn_host = params[:fsn_host]  
    @subject = params[:subject_line]
    @recipients = params[:recipient]
    @from = 'escent_discussion_share<noreply@escentpartners.com>'
    @sent_on = Time.now
    @body = {:message => message, :fsn_host => @fsn_host}
  end 
  
  def share_blog(params)
    user = params[:user]
    message = params[:message]    
    from = params[:sender_email]
    blog = params[:blog]
    @fsn_host = params[:fsn_host]  
      
    @subject = "Invitation From #{user.first_name}"
    @recipients = from
    @from = 'escent_share<noreply@escentpartners.com>'
    @sent_on = Time.now
    @body = {:user => user, :message => message, :blog => blog, :fsn_host => @fsn_host}
  end
  
  def invite_friend(params)
    user = params[:user]
    message = params[:message]
    from = params[:sender_email]
    organization = params[:organization]
    
    #    @subject = "#{user.first_name} need some text for invite friend"
    @subject = "#{user.first_name} Asks \"Will You Pledge a Minute to Pray for Peace?\""
    @recipients = from
#    @from = 'odysseyinvite@odysseynetworks.org'
    @from = "peacepledge@odysseynetworks.org"
    @sent_on = Time.now
    @body = {:user => user, :message => message, :organization => organization}
  end

  def contact_us(params)
    @subject = "Escent Contact Us/Feedback Message"
    @recipients = ['brian@escentpartners.com','allen@escentpartners.com']
    @from = "(" + params[:contact_info][:last_name] + ", " +
    params[:contact_info][:first_name] + ") " +
    params[:contact_info][:email]
    @sent_on = Time.now
    
    part(:content_type => "text/html",
    :body => render_message("contact.text.html.erb",
    :html_body => params[:contact_info][:body],
    :first_name => params[:contact_info][:first_name],
    :last_name => params[:contact_info][:last_name],
    :title => params[:contact_info][:title])) unless params[:contact_info][:body].blank?
    
    #		part(:content_type => "text/plain",
    #			:body => render_message("contact_us.text.plain.erb",
    #				:plain_body => params[:contact_info][:body],
    #				:first_name => params[:contact_info][:first_name],
    #				:last_name => params[:contact_info][:last_name],
    #				:title => params[:contact_info][:title])) unless params[:contact_info][:body].blank?
  end
  
  def email_reminder(preferred_email, prayer_pledge, sent_at = Time.now)
    subject "Pledge Reminder"
    recipients preferred_email
    from       'odysseypledge@odysseynetworks.org'
    sent_on    sent_at
    body       :prayer_pledge => prayer_pledge
  end
  
  def email_reminder_es(preferred_email, prayer_pledge, sent_at = Time.now)
    subject "Odyssey Networks"
    recipients preferred_email
    from       'odysseypledge@odysseynetworks.org'
    sent_on    sent_at
    body       :prayer_pledge => prayer_pledge
  end
  
end