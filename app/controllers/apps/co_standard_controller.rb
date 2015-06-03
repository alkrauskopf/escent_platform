class Apps::CoStandardController < Site::ApplicationController

 layout "site", :except =>[:subject_standards]

  
#  x before_filter :clear_notification
  
 
  def index
  end

  def subject_standards
    
    @co_master = ActMaster.find(:first, :conditions =>["abbrev = ?", "CO"]) 
    @current_standard = @current_user.act_master
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
     if params[:subject_id]
      @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
    end   
    @grade_level = CoGradeLevel.find_by_id(params[:gl_id]) rescue nil
    @standards_list = ActStandard.find(:all, :conditions => ["act_master_id = ? && act_subject_id = ?", @co_master.id, @current_subject.id])
    @standards_list = @standards_list.sort_by{|a| [a.abbrev]}
    if @current_user.has_authorization_level_for?(@current_organization, "ifa_administrator")
      @edit_authorized = true
      end
  end



end
