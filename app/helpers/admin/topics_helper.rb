module Admin::TopicsHelper
  
  def show_content_table_header
    content_tag(:thead,
      content_tag(:tr,
        content_tag(:th, "Title") +
        content_tag(:th, "Contributor") +
        content_tag(:th, "Format") +
        content_tag(:th, "")
      )
    )		
  end
  
  def show_dialog_table_header
    content_tag(:thead,
      content_tag(:tr,
        content_tag(:th, "Select") +
        content_tag(:th, "Title") +
        content_tag(:th, "Resource Type") +        
        content_tag(:th, "Contributor") +
        content_tag(:th, "Format") +
        content_tag(:th, "&nbsp;")        
      )
    )
  end
  def should_select(i)
    if @who_may_contribute_value_settings.is_a?(Array) && i.to_s == "roles"
      true
    elsif @who_may_contribute_value_settings.is_a?(String) && i.to_s == "all"
      true
    elsif @who_may_contribute_value_settings.is_a?(Array) 
      @who_may_contribute_value_settings.include?(i.to_s)
    else
      false
    end
  end
end
