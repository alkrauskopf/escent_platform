class AppMaintenance::IfaController < ApplicationController

  layout "ifa_maint", :except =>[:standard_select]

  before_filter :set_ifa, :except=>[]
  before_filter :current_org_current_app_provider?, :except=>[]
  before_filter :current_user_app_superuser?, :except => []
  before_filter :clear_notification, :except => []
  before_filter :current_standard, :except => []
  before_filter :current_subject, :except => []

  def index
    strands
    current_strand
  end

  def standard_select
    strands
    current_strand
    render :partial =>  "manage_standard", :locals=>{}
  end

  def strand_select
    strands
    current_strand
    render :partial =>  "manage_strands", :locals=>{}
  end

  def strand_update
    strands
    current_strand
    @current_strand.update_attributes(:name=>params[:name], :abbrev => params[:abbrev], :description=>params[:description],
    :strand_background=>params[:strand_background], :strand_font=>params[:strand_font])
    render :partial =>  "edit_strand", :locals=>{:strand => @current_strand}
  end

  private

  def current_standard
    if params[:act_master_id]
      @current_standard = ActMaster.find_by_id(params[:act_master_id]) rescue ActMaster.default
    else
      @current_standard = ActMaster.default
    end
  end
  def current_subject
    if params[:act_subject_id]
      @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    else
      @current_subject = ActSubject.first
    end
  end

  def strands
    @strands = ActStandard.for_standard_and_subject(@current_standard, @current_subject)
  end

  def current_strand
    if !@strands.empty?
      if params[:act_standard_id]
        @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue @strands.first
      else
        @current_strand = @strands.first
      end
    else
      @current_strand = nil
    end
  end
end
