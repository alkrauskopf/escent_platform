class Apps::ClassOfferingController < ApplicationController

  helper :all # include all helpers, all the time
  layout "offering", :except =>[ ]

  before_filter :set_classroom, :except=>[]
  before_filter :find_featured_topic, :only => [:index]
  before_filter :classroom_allowed?, :except=>[]
 # before_filter :current_user_app_authorized?, :except=>[:index]
  before_filter :clear_notification
  before_filter :increment_app_views, :only=>[:index]
  protect_from_forgery :except => []


  def index
    current_app_enabled_for_current_org?
#    initialize_site_parameters
#    initialize_std_parameters
    @classroom.increment_views
    if @current_user
      @clsrm_leaders = @current_user.student_of_classroom?(@classroom) ? @classroom.teachers_for_student(@current_user) : @classroom.leaders
      current_period
    else
      @clsrm_leaders = @classroom.leaders
      @current_classroom_period = nil
    end
    @topics_list = @classroom.topics.sort{ |a,b| a.estimated_start_date <=> b.estimated_start_date }
    @homeworks_list = @classroom.homeworks.active
    @sms_topics = []

    unless @current_user.nil?
      @teacher_homeworks = @homeworks_list.select{|h|h.teacher_id == @current_user.id}
      @teacher_assessments = @classroom.act_submissions.select{|s| (s.teacher_id == @current_user.id && !s.is_final)}

# get student sms for classroom

      if @current_provider.ifa_org_option
        @latest_dashboard = @current_user.ifa_dashboards.for_subject_since(@classroom.act_subject, @school_options.begin_school_year).last rescue nil
        teacher_fav_topics = []
        @classroom.leaders.each do |l|
          teacher_fav_topics += l.favorite_classrooms.collect{|c| c.topics}.flatten
        end
        @sms_topics = teacher_fav_topics.select{|t| t.act_score_range.for_standard(@current_standard).first.upper_score >= @student_sms_score && t.act_score_range.for_standard(@current_standard).first.lower_score <= @student_sms_score} rescue nil
      end
    end
    if @current_topic
      @discussions = @current_topic.discussions.active.parent_id_blank(:order_by =>  "created_at DESC")
    else
      @discussions = []
    end
    render :layout => 'offering'
  end

  private

  def classroom_allowed?
    current_app_enabled_for_current_org?
  end

  def current_period
    @current_classroom_period = @classroom.period_for_student(@current_user)
    if @current_classroom_period.nil?
      @current_classroom_period = (@classroom.classroom_periods.empty? || @classroom.classroom_periods.size > 1) ? nil : @classroom.classroom_periods.first
    end
  end

  # NEEDS Re-Write:   Victor rewrite find_featured_topic method for tcpj
  def find_featured_topic
    @current_classroom ||= (Classroom.find_by_public_id(params[:id]) rescue @current_organization.classrooms.active.first)
    unless @current_classroom
      @current_classroom = Classroom.all.first
    end
    @classroom = @current_classroom
    if !params[:topic_id].blank?
      @current_topic = Topic.find_by_public_id params[:topic_id]
      @return_topic = @current_topic
    elsif @current_classroom && @current_classroom.featured_topic
#    elsif @current_classroom.featured_topic && @current_classroom.featured_topic.active?
      @current_topic = @current_classroom.featured_topic
      @return_topic = []
    else
      @current_topic = @current_classroom.topics.active.first rescue nil
      @return_topic = []
    end
    if (@current_topic && @current_topic.featured_content)
      @content = Content.find(@current_topic.featured_content) rescue nil
    end
    if (@current_topic && @current_topic.contents.size>0)
      @related_content = @content ? @current_topic.contents.select{|r| r != @content} : @current_topic.contents
    else
      @related_content = []
    end
    if @content.nil? && @related_content.size == 1
    then @content = @related_content.first
    @related_content = []
    end
#    @related_content = @current_topic ? @current_topic.contents.active - [@content] : []
    @other_active_topics = @current_classroom ? @current_classroom.topics.active.collect{|t| t} - [@current_classroom.featured_topic || @current_classroom.topics.active.first] : []
  end

  def initialize_site_parameters_x
    if params[:organization_id]
      @current_organization = Organization.find_by_public_id(params[:organization_id]) rescue nil
    end
    if params[:user_id]
      @current_user = User.find_by_public_id(params[:user_id]) rescue nil
    end
    if params[:app_id]
      @app = CoopApp.find_by_id(params[:app_id]) rescue nil
    end
  end

  def initialize_std_parameters_x
    @standards = ActStandard.all.collect{|s|[s.standard]}.uniq.sort
    if @current_user
      @std_view = @current_user.std_view.to_s
      @current_standard = ActMaster.default
    else
      @std_view = "act"
      @current_standard = ActMaster.default
    end
  end
end
