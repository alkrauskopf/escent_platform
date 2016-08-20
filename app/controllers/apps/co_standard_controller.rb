class Apps::CoStandardController < ApplicationController

 layout "ifa", :except =>[:subject_standards]
 before_filter :ifa_allowed?, :except=>[]
 before_filter :current_user_app_authorized?, :except=>[]
 before_filter :current_user_app_admin?, :only=>[]
 before_filter :clear_notification
 before_filter :increment_app_views, :only=>[:index]
  
 
  def index
  end

  def subject_standards
    @co_master = ActMaster.co.first
    @current_standard = @current_user.act_master
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
     if params[:subject_id]
      @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
    end   
    @grade_level = CoGradeLevel.find_by_id(params[:gl_id]) rescue nil
 #   @standards_list = ActStandard.find(:all, :conditions => ["act_master_id = ? && act_subject_id = ?", @co_master.id, @current_subject.id])
    @standards_list = ActStandard.for_standard_and_standard(@co_master, @current_subject)
    @standards_list = @standards_list.sort_by{|a| [a.abbrev]}
    if @current_user.ifa_admin_for_org?(@current_organization)
      @edit_authorized = true
      end
  end

 private

 def ifa_allowed?
   @current_application = CoopApp.ifa
   @current_provider = @current_organization.app_provider(@current_application)
   current_app_enabled_for_current_org?
 end

end
