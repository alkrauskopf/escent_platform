class Master::DiscussionsController < Master::ApplicationController
    layout "master"
    
    def discussion_abuses
      @discussions = Discussion.all.paginate :per_page => 10, :page => params[:page]
    end
end
