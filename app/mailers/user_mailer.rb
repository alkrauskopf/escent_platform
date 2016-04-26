class UserMailer < ApplicationMailer


  def reset_password(user, password, ep_host)
    @password = password
    @user = user
    @ep_host = ep_host
    @organization = !@user.organization.nil? ? @user.organization : Organization.ep_default.first
    @subject_line = 'Escent Password Reset'
    @recipients = @user.preferred_email
    @from = "escent_passwords<noreply@escentpartners.com>"
    sent_on  Time.now
    unless @recipients.blank? || @organization.nil?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

  def new_authorization(user, organization, authorizer, authorization, ep_host)
    @from = "escent_authorization<noreply@escentpartners.com>"
    @auth_level = authorization
    @organization = organization
    @authorizer = authorizer
    @user = user
    @send_to = @user.preferred_email.nil? ? @user.email_address : @user.preferred_email
    @ep_host = ep_host
    @subject_line =  organization.medium_name + ' ' + @auth_level.name.humanize + " Authorization"
    sent_on  Time.now
    mail(to: @send_to, subject: @subject_line, from: @from)
  end

  def survey_notification(user, anon, subject_line, administrator, organization, ep_host)
    @ep_host = ep_host
    @organization = organization
    @anon_text = anon ? ' anonymous' : ''
    @administrator = administrator
    @subject_line = subject_line
    @user = user
    @send_to = @user.preferred_email.nil? ? @user.email_address : @user.preferred_email
    @from = "escent_survey<noreply@escentpartners.com>"
    sent_on  Time.now
    mail(to: @send_to, subject: @subject_line, from: @from)
  end

  def contact_us(params)
    @subject = "Escent Contact Us/Feedback Message"
    @recipients = Organization.default.administrator_email_list
    @from = params[:contact_info][:email]
    @sent_on = Time.now
    @body = params[:contact_info][:body].html_safe
    @contactee = params[:contact_info][:last_name] + ", " +
        params[:contact_info][:first_name]
    @title = params[:contact_info][:title]
    sent_on  Time.now
    unless @recipients.empty?
      mail(to: @recipients, subject: @subject, from: @from)
    end
  end

  def contact(sender_email, options = {})
    sent_on      Time.now
    @recipients = user.preferred_email
    @subject_line = options[:subject]
    @user = options[:user]
    @send_to = @user.preferred_email.nil? ? @user.email_address : @user.preferred_email
    @from = sender_email
    @body = options[:html_body]
    mail(to: @recipients, subject: @subject_line, from: @from)
  end

  def admin_notice(user, organization, ep_host)
    @organization = organization
    @recipients = @organization.administrator_email_list
    @user = user
    @ep_host = ep_host
    @subject_line = @organization.short_name + ' Escent Registration'
    @from = 'escent_registration<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipients.empty?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

  def assessment_submission(recipient, sender, classroom, organization, must_review, ep_host)
    @organization = organization
    @classroom = classroom
    @sender = sender
    @recipient = recipient
    @subject_line = @sender.full_name + " Submitted An Assessment"
    @ep_host = ep_host
    @review_msg = must_review ? "Your Review Of The Assessment Is Required." : "Assessment Results Have Been Automatically Finalized."
    @from = 'escent_assessment<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipients.blank? || @sender.blank?
      mail(to: @recipient, subject: @subject_line, from: @from)
    end
  end

  def share_app_blog(organization, sender, blog_id, recipients, message, subject, ep_host )
    @sender = sender
    @message = message
    @blog = Blog.find_by_public_id(blog_id) rescue nil
    @ep_host = ep_host
    @subject_line = subject
    @recipients = recipients
    @organization = organization
    @from = 'escent_discussion_share<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipients.blank? || @organization.nil? || @blog.nil? || @sender.blank?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

  def share_blog(blog, sender, recipient, message, ep_host)
    @ep_host = ep_host
    @sender = sender
    @message = message
    @recipient = recipient
    @blog = blog
    @subject_line = "Invitation From #{user.first_name}"
    @from = 'escent_blog_share<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipient.blank? || @organization.nil? || @blog.nil? || @sender.blank?
      mail(to: @recipient, subject: @subject_line, from: @from)
    end
  end

  def inform_blogger(blog, blog_post, user, comment, ep_host)
    @ep_host = ep_host
    @user = user
    @comment = comment
    @blog = blog
    @blog_post = blog_post
    @subject_line  = 'Blog Comment Notification'
    @recipient = @blog_post.user.preferred_email
    @from = 'escent_blogging<noreply@escentpartners.com>'
    sent_on    Time.now
    unless @recipient.blank? || @sender.blank?
      mail(to: @recipient, subject: @subject_line, from: @from)
    end
  end

  def observation_invite(recipient, sender, arrangement, message)
    @sender = sender
    @recipient = recipient
    @message = message
    @arrangement = arrangement
    @subject_line = "Invitation From #{@sender.first_name}"
    if params[:arrange].blank?
      @arrange = @sender.full_name + " invites you to arrange a classroom observation."
    else
      @arrange = params[:arrange] == "1" ? (@sender.full_name + " would like to observe your classroom.") : ("Would you be willing to be a classroom observer of " + @sender.full_name + "?" )
    end
    @from = 'escent_time_learning<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipient.blank? || @sender.blank?
      mail(to: @recipient, subject: @subject_line, from: @from)
    end
  end

  def itl_belt_change(recipient, sender, belt_id, message, ep_host)
    @belt = ItlBeltRank.find_by_id(belt_id) rescue nil
    unless @belt.nil?
      @ep_host = ep_host
      @sender = sender
      @recipient = recipient
      @message = message
      @subject_line = 'Observation Proficieny Level Change'
      @from = 'escent_time_learning<noreply@escentpartners.com>'
      sent_on  Time.now
      unless @recipient.blank? || @sender.blank?
        mail(to: @recipient, subject: @subject_line, from: @from)
      end
    end
  end

  def share_content(organization, resource, user, recipients, message, ep_host)
    @ep_host = ep_host
    @user = user
    @message = message
    @recipients = recipients
    @content = resource
    @organization = organization
    @subject_line = "Invitation From #{@user.full_name}"
    @from = 'escent_resource_share<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipients.blank?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

  def resource_changed(recipient_list, user, title, resource, change)
    @recipients = recipient_list
    @change_text = change == 'D' ? 'removed from the Resource Library' : ' updated'
    @user = user
    @orig_title = title
    @subject_line = "Classroom Resource Removal Notification"
    @from =  'escent_resource_library<noreply@escentpartners.com>'
    sent_on    Time.now
    unless @recipients.blank?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

  def resource_comment(user, commenter, resource, discussion, ep_host)
    @ep_host = ep_host
    @recipient = user.preferred_email
    @commenter = commenter
    @organization = @content.organization rescue nil
    @user = user
    @content = resource
    @resource_comment = discussion
    @subject_line = "Resource Comment Notification"
    @from  = 'escent_resource_library<noreply@escentpartners.com>'
    sent_on    Time.now
    unless @recipient.blank?
      mail(to: @recipient, subject: @subject_line, from: @from)
    end
  end

  def topic_comment(recipient_list, user, topic, discussion, ep_host)
    @ep_host = ep_host
    @recipients = recipient_list
    @sender = user
    @topic = topic
    @topic_comment = discussion
    @organization = @topic.classroom.organization rescue nil
    @subject_line =  "Discussion Comment Notification"
    @from = 'escent_classroom<noreply@escentpartners.com>'
    sent_on    Time.now
    unless @recipients.blank? || @organization.nil?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

  def share_discussion(organization, topic, user, recipients, message, ep_host)
    @ep_host = ep_host
    @user = user
    @message = message
    @recipients = recipients
    @topic = topic
    @organization = organization
    @subject_line = "Invitation From #{@user.full_name}"
    @from = 'escent_offering<noreply@escentpartners.com>'
    sent_on  Time.now
    unless @recipients.blank? || @topic.classroom.nil?
      mail(to: @recipients, subject: @subject_line, from: @from)
    end
  end

end
