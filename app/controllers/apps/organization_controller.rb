  class Apps::OrganizationController < ApplicationController

    helper :all # include all helpers, all the time
    layout "organization", :except=>[:summarize_org_app]

    before_filter :core_allowed?
    before_filter :increment_current_org_views, :only => [:static_organization]
    before_filter :clear_notification


    def static_organization
      unless @current_organization.default?
        initialize_std_parameters
      else
        redirect_to  root_path
      end
    end

    def summarize_org_app
      @app = CoopApp.find_by_public_id(params[:app_id])
      @provider = @current_organization.app_provider(@app) ? @current_organization.app_provider(@app) : Organization.default
      @is_provider =  @provider == @current_organization
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
