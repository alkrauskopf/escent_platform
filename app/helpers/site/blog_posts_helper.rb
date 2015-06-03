module Site::BlogPostsHelper
  def admin?(blog_post , current_user)
    current_user.present? ? blog_post.user == current_user : false
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

end
