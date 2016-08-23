class Apps::ResourceLibraryController < ApplicationController

  helper :all # include all helpers, all the time

    layout "resource", :except=>[]

    before_filter :core_allowed?, :except=>[]
    before_filter :current_user_app_authorized?, :except=>[]
    before_filter :clear_notification


    def static_resource
      initialize_std_parameters
      if params[:id]
        @content = Content.find_by_public_id(params[:id])
      else
        @content = @current_organization.contents.first
      end
      @content_topics = []
      if @content
        @mastery_level = @content.act_score_ranges.for_standard(@current_standard).first rescue nil
        @strands = @content.act_standards.for_standard(@current_standard) rescue nil
        @discussions = @content.discussions.active.parent_id_blank(:order_by =>  "created_at DESC")
        @content_topics = @content.topics.active
        @current_subject = @content.act_subject rescue nil
      else
        @discussions = []
      end
      @content_org = @content.organization ? @content.organization : Organization.ep_default.first
    end

  private

  def core_allowed?
    @current_application = CoopApp.core
  end

    def initialize_std_parameters
      @standards = ActStandard.all.collect{|s|[s.standard]}.uniq.sort
      if @current_user
        @std_view = @current_user.std_view.to_s
        @current_standard = @current_user.act_master
      else
        @std_view = "act"
        @current_standard = ActMaster.all.first
      end
    end
end
