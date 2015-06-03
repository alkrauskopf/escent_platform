module Site::DiscussionsHelper
  include ApplicationHelper
  def permission_to_add_comment?
    if @current_user && @current_topic
      who_may_contribute_value_settings = YAML::load(@current_topic.discussion_setting_value_named('Permission To Contribute'))
      if who_may_contribute_value_settings.is_a?(String) && who_may_contribute_value_settings == "all"
        true
      elsif who_may_contribute_value_settings.is_a?(Array)
        role_ids = @current_user.roles.collect{|r| r.id.to_s}
        !(role_ids & who_may_contribute_value_settings).empty?
      end
    else
      false
    end
  end 
  
  def show_discussion_is_delete?(comment, is_delete)
    if is_delete
      "** This comment has been deleted **"
    else
      to_br(comment)
    end
  end
end