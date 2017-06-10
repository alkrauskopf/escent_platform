class Ifa::QuestionRepoController < Ifa::ApplicationController

  layout "ifa_repo", :except=>[:new]

  before_filter :current_user_app_authorized?
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_app_superuser
  before_filter :current_subject, :except => [:index]
  before_filter :clear_notification, :except => []

  def index
    ifa_subjects
    if params[:act_subject] && params[:act_subject][:id] && params[:act_subject][:id] != ''
      @current_subject = ActSubject.find_by_id(params[:act_subject][:id]) rescue ActSubject.all_subjects.first
    else
      current_subject
    end
    related_readings
    @function = 'Create'
    @current_question = ActQuestion.new
  end

  def reading_select
    related_readings
    get_current_reading
    @current_reading_text = @current_reading.nil? ? '' : @current_reading.reading
    render :partial => 'form_question_reading'
  end

  def strand_select
    get_current_question
    get_current_strand
    if @current_question.strands.include?(@current_strand)
      @current_question.strand_remove(@current_strand)
    else
      @current_question.act_standards << @current_strand
    end
    available_strands_levels(@current_question)
    render :partial =>  "update_question_tags"
  end

  def level_select
    get_current_question
    get_current_level
    if @current_question.levels.include?(@current_level)
      @current_question.level_remove(@current_level)
    else
      @current_question.act_score_ranges << @current_level
    end
    available_strands_levels(@current_question)
    render :partial =>  "update_question_tags"
  end

  def create
    ifa_subjects
  #  levels_and_strands
    related_readings
    get_current_reading
    if function == 'Create'
      @current_question = ActQuestion.new
    else
      get_current_question
    end
    if !@current_question.nil?
      update_question
      available_strands_levels(@current_question)
    else
      flash[:error] = 'Could Create Question Object'
    end
    @current_reading_text = (@current_question.nil? || @current_question.act_question_reading.nil?) ? '' : @current_question.act_question_reading.reading
    render :index
  end

  def choice_create
    get_current_question
    choice = ActChoice.new
    choice.position = params[:position]
    choice.choice = params[:description]
    choice.act_question_id = @current_question.id
    if !choice.save
      flash[:error] = choice.errors.full_messages.to_sentence
    end
    render :partial =>  "update_question_choices"
  end

  def choice_active
    get_current_question
    get_current_choice
    @current_choice.update_attributes(:is_active => !@current_choice.is_active)
    render :partial =>  "update_question_choices"
  end

  def choice_correct
    get_current_question
    get_current_choice
    @current_choice.update_attributes(:is_correct => !@current_choice.is_correct)
    render :partial =>  "update_question_choices"
  end

  def choice_destroy
    get_current_question
    get_current_choice
    @current_choice.destroy
    render :partial =>  "update_question_choices"
  end

  def choice_update
    get_current_question
    get_current_choice
    if @current_choice.update_attributes(:position => params[:position], :choice => params[:description])
      flash[:notice] = "Choice Update"
    else
      flash[:error] = @current_choice.errors.full_messages.to_sentence
    end
    render :partial =>  "update_question_choices"
  end

  private

  def function
    @function = params[:function] ? params[:function]: nil
    @function
  end

  def ifa_subjects
    @ifa_subjects = ActSubject.all_subjects
  end

  def tinymce_param
    @current_subject.id.to_s + @current_strand.id.to_s + @current_level.id.to_s
  end

  def levels_and_strands
    @current_ifa_levels = ActScoreRange.for_standard_and_subject(@current_standard, @current_subject)
    @current_ifa_strands = ActStandard.for_standard_and_subject(@current_standard, @current_subject)
  end

  def get_current_strand
    if params[:act_standard_id]
      @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    end
  end

  def get_current_level
    if params[:act_score_range_id]
      @current_level = ActScoreRange.find_by_id(params[:act_score_range_id]) rescue nil
    end
  end

  def get_current_reading
    @current_reading_text = ""
    if params[:act_rel_reading_id]
      @current_reading = ActRelReading.find_by_id(params[:act_rel_reading_id]) rescue nil
    end
  end

  def get_current_question
    if params[:act_question_id]
      @current_question = ActQuestion.find_by_id(params[:act_question_id]) rescue nil
    end
  end

  def get_current_choice
    if params[:act_choice_id]
      @current_choice = ActChoice.find_by_id(params[:act_choice_id]) rescue nil
    end
  end

  def related_readings
    @rel_readings = @current_subject.nil? ? [] : @current_subject.act_rel_readings.sort_by{|r| r.label}.collect{|r| [r.label,r.id]}
    @rel_readings = @rel_readings.insert(0,["- - No Reading - -", 0])
  end

  def update_question
    @current_question.act_rel_reading_id = params[:act_rel_reading_id] == '0' ? nil : params[:act_rel_reading_id].to_i
    @current_question.question = params[:act_question][:question]
    @current_question.comment = params[:act_question][:comment]
    @current_question.question_type = params[:act_question][:question_type] == '' ? @current_question.question_type : params[:act_question][:question_type]
    @current_question.is_random = params[:act_question][:is_random]
    @current_question.is_calc_free = params[:act_question][:is_calc_free]
    @current_question.act_subject_id = @current_subject.id
    @current_question.user_id = @current_user.id
    @current_question.organization_id = @current_organization.id
    if @current_question.save
      flash[:notice] = "Question #{function} Successful"
      @function = 'Update'
      if params[:act_rel_reading_id] != '0'
        reading = params[:act_rel_reading_id]
        question_reading = ActQuestionReading.new
        question_reading.reading = (params[:act_question_reading] && params[:act_question_reading][reading]) ? params[:act_question_reading][reading] : nil
       if !question_reading.reading.nil?
        @current_question.act_question_reading = question_reading
       end
      else
        if !@current_question.act_question_reading.nil?
          @current_question.act_question_reading.destroy
        end
      end
    else
      flash[:error] = @current_question.errors.full_messages.to_sentence
    end
  end

  def available_strands_levels(question)
    @available_strands = @current_provider.knowledge_strands_subject(question.act_subject) - question.strands
    @available_levels = @current_provider.knowledge_levels_subject(question.act_subject) - question.levels
  end

end
