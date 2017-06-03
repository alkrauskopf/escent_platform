class Ifa::QuestionRepoController < Ifa::ApplicationController

  layout "ifa_repo", :except=>[]

  before_filter :current_user_app_authorized?
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_app_superuser
  before_filter :current_subject
  before_filter :clear_notification, :except => []

  def index
    ifa_subjects
    current_levels_and_strands
  end

  def subject_select
    ifa_subjects
    current_levels_and_strands
    render :partial => 'create_question_selects'
  end

  def new
    ifa_subjects
    current_levels_and_strands

    @current_question = ActQuestion.new
    render :partial => 'form_question'
  end

  def create
    ifa_subjects
    current_levels_and_strands
    @current_question = ActQuestion.new

    render :partial => 'create_question_selects'
  end

  private

  def ifa_subjects
    @ifa_subjects = ActSubject.all_subjects
  end

  def tinymce_param
    @current_subject.id.to_s + @current_strand.id.to_s + @current_level.id.to_s
  end

  def current_levels_and_strands
    @current_ifa_levels = ActScoreRange.for_standard_and_subject(@current_standard, @current_subject)
    @current_ifa_strands = ActStandard.for_standard_and_subject(@current_standard, @current_subject)
    get_current_strand
    get_current_level
  end

  def get_current_strand
    if params[:act_standard_id]
      @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    else
      @current_strand = @current_ifa_strands.first
    end
  end

  def get_current_level
    if params[:act_score_range_id]
      @current_level = ActScoreRange.find_by_id(params[:act_score_range_id]) rescue nil
    else
      @current_level = @current_ifa_levels.first
    end
  end

end
