class HelpController < ApplicationController
  layout "fsn"
  
  before_filter :current_user
    
  def index
    render :layout => "ep_site2"
  end
end
