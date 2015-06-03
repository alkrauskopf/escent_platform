# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def to_br(str)
    str.to_s.gsub!(/\r?\n/, '<br/>') unless str.blank?
#    str.to_s.gsub!(' ', '&nbsp') unless str.blank?
    return str
  end

  def vaild_tag
    "<span style='color:#C73914;'>*<\/span> "
  end
  
  def show_audio_player(file_url)
    %Q(
        <object type="application/x-shockwave-flash" data="/audio_player/player.swf" id="audioplayer1" height="24" width="240">
        <param name="movie" value="/audio_player/player.swf">
        <param name="FlashVars" value="playerID=1&amp;soundFile=#{file_url} %>">
        <param name="quality" value="high">
        <param name="menu" value="false">
        <param name="wmode" value="transparent">
        </object> 
     )
  end

 def pdf_image_tag(image, options = {})
  options[:src] = File.expand_path(RAILS_ROOT) + '/public' + image
  tag(:img, options)
 end 

end
