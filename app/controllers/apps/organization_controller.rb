  class Apps::OrganizationController < ApplicationController

    helper :all # include all helpers, all the time
    layout "organization", :except=>[:summarize_org_app, :summarize_org_subject_offerings]

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
      @is_provider =  @app.providers.include?(@current_organization)
      @provider = !@is_provider ? @current_organization.app_provider(@app) : @current_organization
    end

    def summarize_org_subject_offerings
      @subject = params[:subject_area_id] ? SubjectArea.find_by_public_id(params[:subject_area_id]): nil
      @folder = params[:folder_id] ? Folder.find_by_public_id(params[:folder_id]): nil
      @display = params[:display]
      if !@subject.nil?
        @unfoldered_offerings = (@display == "Offering") ? (@current_organization.unfoldered_active_offerings.select{|c| c.subject_area.id == @subject.id || c.subject_area.parent_id == @subject.id}.sort_by{|c| [c.subject_area.name, c.course_name]}) :
            (@current_organization.unfoldered_active_offerings.select{|c| c.featured_topic && (c.subject_area.id == @subject.id || c.subject_area.parent_id == @subject.id)}.sort_by{|c| [c.subject_area.name, c.course_name]})
      else
        @unfoldered_offerings = []
      end
      if !@folder.nil?
      @foldered_offerings = (@display == "Offering") ? (@current_organization.active_offerings_in_folder(@folder)) :
          (@current_organization.active_offerings_in_folder(@folder).select{|c| c.featured_topic})
      else
        @foldered_offerings = []
      end
      @no_keys = Classroom.all_open?(@unfoldered_offerings + @foldered_offerings)
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
