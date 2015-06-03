class Master::DiscussionsController < Master::ApplicationController
    layout "master"
    
    def discussion_abuses
      @discussions = Discussion.find(:all).paginate :per_page => 10, :page => params[:page]
    end
end
