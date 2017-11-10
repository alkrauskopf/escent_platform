class Ifa::QuestionRepoController < Ifa::ApplicationController

  layout "ifa_repo", :except=>[:question_list]

  before_filter :current_user_app_authorized?
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_app_superuser
  before_filter :current_user_app_admin
  before_filter :current_subject, :except => [:index]
  before_filter :clear_notification, :except => []

  def index_old
    ifa_subjects
    get_current_assessment
    if params[:act_subject] && params[:act_subject][:id] && params[:act_subject][:id] != ''
      @current_subject = ActSubject.find_by_id(params[:act_subject][:id]) rescue ActSubject.all_subjects.first
    else
      current_subject
    end
    related_readings
    @function = 'Create'
    @current_question = ActQuestion.new
  end

  def index
    ifa_subjects
    get_subject
    get_level
    get_strand
    get_current_assessment
    related_readings
    @function = 'Create'
    @current_question = ActQuestion.new
  end

  def subject_select
    get_subject
    question_dashboard
    render :partial => "manage_questions"
  end

  def cell_show
    get_subject
    get_level
    get_strand
    question_dashboard
    @question_list = @current_subject.act_questions.all_for_level_strand(@current_level, @current_strand)
    render :partial => "manage_questions"
  end

  def reading_select
    related_readings
    get_current_reading
    @current_reading_text = @current_reading.nil? ? '' : @current_reading.reading
    render :partial => 'form_question_reading'
  end

  def rl_select
    get_current_question
    get_resource_list
    render :partial =>  "update_question_rls", :locals => {:resource_type => resource_type}
  end

  def resource_attach
    get_current_question
    @current_question.update_attributes(:content_id => params[:resource_id])
    get_resource_list
    render :partial =>  "update_question_rls", :locals => {:resource_type => resource_type}
  end

  def assessment_select
    get_current_question
    get_current_assessment
    if @current_question.all_assessments.include?(@current_assessment)
      @current_question.assessment_remove(@current_assessment)
    else
      assign_question_assessment
    end
    available_assessments(@current_question)
    available_benchmarks(@current_question)
    render :partial =>  "update_question_assignments"
  end

  def toggle_active
    get_current_question
    if params[:function] == 'Active'
      @current_question.update_attributes(:is_active => !@current_question.is_active)
    elsif params[:function] == 'Calibrate'
      @current_question.update_attributes(:is_calibrated => !@current_question.is_calibrated)
    end
#    available_strands_levels(@current_question)
#    available_benchmarks(@current_question)
#    available_assessments(@current_question)
    render :partial =>  "update_question_choices"
  end

  def benchmark_attach
    get_current_question
    get_current_benchmark
    if @current_question.all_benchmarks.include?(@current_benchmark)
      @current_question.act_bench_act_questions.for_bench(@current_benchmark).destroy_all
    elsif
      @current_question.act_benches << @current_benchmark
    end
    available_benchmarks(@current_question)
    render :partial =>  "update_question_benchmarks"
  end

  def edit
    get_current_question
    ifa_subjects
    get_subject
    @current_level = @current_question.mastery_level
    @current_strand = @current_question.strand
    related_readings
    @function = 'Update'
    available_strands_levels(@current_question)
    available_benchmarks(@current_question)
    available_assessments(@current_question)
    @current_reading = @current_question.reading.nil? ? nil : @current_question.act_rel_reading
    @current_reading_text = (@current_question.nil? || @current_question.act_question_reading.nil?) ? '' : @current_question.act_question_reading.reading
    render :index
  end

  def create
    ifa_subjects
    get_subject
    get_level
    get_strand
    related_readings
    get_current_reading
    get_current_assessment
    if function == 'Create'
      @current_question = ActQuestion.new
    else
      get_current_question
    end
    if !@current_question.nil?
      update_question
      available_strands_levels(@current_question)
      available_benchmarks(@current_question)
      available_assessments(@current_question)
    else
      flash[:error] = 'Could Not Create Question Object'
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

  def question_destroy
    get_current_question
    @current_question.destroy
    question_list
  end

  def question_list
    if params[:entity_id] == '0'
      @entity_questions = ActQuestion.untagged
    else
      get_entity
      @entity_questions = @current_entity.act_questions.by_date
    end
    question_creators
    current_strands(:standard=>@current_standard)
    render :partial =>  "question_list"
  end

  def preview_question
    get_current_question
    render :layout => "act_assessment"
  end

  def static_question
    get_current_question

  end
  private

  def get_entity
    if params[:entity_class] == 'User'
      @current_entity = User.find_by_id(params[:entity_id]) rescue nil
    elsif params[:entity_class] == 'ActStandard'
      @current_entity = ActStandard.find_by_id(params[:entity_id]) rescue nil
    end
  end

  def resource_type
    params[:resource_type] ? params[:resource_type]: nil
  end

  def get_resource_list
    @resource_list = @current_user.favorite_resources.select{|r| (r.content_object_type.content_object_type_group.name == resource_type) }.sort{ |a, b| b.updated_at <=> a.updated_at } rescue []
    @resource_list -= [@current_question.content]
  end

  def function
    @function = params[:function] ? params[:function]: nil
    @function
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

  def get_current_benchmark
    if params[:act_benchmark_id]
      @current_benchmark = ActBench.find_by_id(params[:act_benchmark_id]) rescue nil
    end
  end

  def get_current_resource
    if params[:resource_id]
      @current_resource = Content.find_by_id(params[:resource_id]) rescue nil
    else
      @current_resource = nil
    end
  end

  def get_current_assessment
    if params[:act_assessment_id]
      @current_assessment = ActAssessment.find_by_id(params[:act_assessment_id]) rescue nil
    else
      @current_assessment = nil
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

  def adjust_levels_strands
    # this is to move away from multiple levels/strands per question
    @current_question.act_question_act_score_ranges.destroy_all
    @current_question.act_question_act_standards.destroy_all
    temp_levels = ActQuestionActScoreRange.new
    temp_levels.act_score_range_id = params[:act_question][:act_score_range_id]
    @current_question.act_question_act_score_ranges << temp_levels
    temp_strands = ActQuestionActStandard.new
    temp_strands.act_standard_id = params[:act_question][:act_standard_id]
    @current_question.act_question_act_standards << temp_strands
  end

  def update_question
    @current_question.act_rel_reading_id = params[:act_rel_reading_id] == '0' ? nil : params[:act_rel_reading_id].to_i
    @current_question.act_standard_id = @current_strand.id
    @current_question.act_score_range_id = @current_level.id
    #  transition from many levels & strands
    adjust_levels_strands
    #
    @current_question.question = params[:act_question][:question]
    @current_question.comment = params[:act_question][:comment]
    @current_question.question_type = params[:question][:question_type] == '' ? @current_question.question_type : params[:question][:question_type]
    @current_question.is_random = params[:act_question][:is_random]
    @current_question.is_enlarged = params[:act_question][:is_enlarged]
    @current_question.is_calc_free = params[:act_question][:is_calc_free]
    @current_question.act_subject_id = @current_subject.id
    @current_question.user_id = @current_user.id
    @current_question.organization_id = @current_organization.id
    @current_question.question_image = params[:act_question][:question_image] ? params[:act_question][:question_image] : @current_question.question_image
    if params[:question_image] && params[:question_image][:delete] == '1'
      @current_question.question_image.destroy
    end
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
      if @current_assessment
        assessment_join = ActAssessmentActQuestion.new
        assessment_join.act_assessment_id = @current_assessment.id
        assessment_join.position = 1
        @current_question.act_assessment_act_questions << assessment_join
        flash[:notice] << ' AND Added To Assessment'
      end
    else
      flash[:error] = @current_question.errors.full_messages.to_sentence
    end
  end

  def available_strands_levels(question)
    @available_strands = @current_provider.knowledge_strands_subject(question.act_subject) - question.strands
    @available_levels = @current_provider.knowledge_levels_subject(question.act_subject) - question.levels
  end

  def available_assessments(question)
    @available_assessments = question.act_subject.act_assessments.active.lock
    @available_assessments -= question.act_assessments
  end

  def assign_question_assessment
    ass_join = ActAssessmentActQuestion.new
    ass_join.act_assessment_id = @current_assessment.id
    ass_join.position = @current_assessment.act_questions.size + 1
    @current_question.act_assessment_act_questions << ass_join
  end

  def available_benchmarks(question)
    if !question.strand.nil? && !question.mastery_level.nil?
      @available_benchmarks = @current_standard.active_benches_strand_range(question.strand, question.mastery_level, ActBenchType.benchmark(@current_standard), :teacher=>'Y')
    else
      @available_benchmarks = []
    end
  end

  def get_subject
    if params[:act_subject_id]
      @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    else
      @current_subject = nil
    end
  end

  def question_dashboard

    @dashboard = {}
    @cell_questions = {}
    @quest_total = {}
    @quest_benchmarks = {}
    @quest_assessments = {}
    @quest_total['all'] = 0
    @quest_total['enabled'] = 0
    @quest_total['calibrated'] = 0
    @quest_benchmarks['all'] = 0
    @quest_assessments['all'] = 0
    @dashboard['strands'] = @current_standard.strands(@current_subject)
    @dashboard['levels'] = @current_standard.mastery_levels(@current_subject)
    @dashboard['levels'].each do |level|
      @quest_total[level.range] = 0
      @quest_total['cal'+level.range] = 0
      @quest_benchmarks[level.range] = 0
      @quest_assessments[level.range] = 0
    end
    @dashboard['strands'].each do |strand|
      @quest_total[strand.abbrev] = 0
      @quest_total['cal'+strand.abbrev] = 0
      @quest_benchmarks[strand.abbrev] = 0
      @quest_assessments[strand.abbrev] = 0
      @dashboard['levels'].each do |level|
        ls = level.id.to_s + strand.id.to_s
        @cell_questions[ls] = @current_subject.act_questions.all_for_level_strand(level, strand)
        @quest_total[ls] = @current_subject.act_questions.enabled_for_level_strand(level, strand).size
        @quest_total[strand.abbrev] += @quest_total[ls]
        @quest_total[level.range] += @quest_total[ls]
        @quest_total['enabled'] += @quest_total[ls]
        @quest_total['all'] += @cell_questions[ls].size
        @quest_total['cal'+ ls] = @cell_questions[ls].select{|q| q.calibrated?}.size
        @quest_total['calibrated'] += @quest_total['cal'+ ls]
        @quest_total['cal'+level.range] += @quest_total['cal'+ ls]
        @quest_total['cal'+strand.abbrev] += @quest_total['cal'+ ls]
        @quest_assessments[ls] =  @cell_questions[ls].map{|q| q.assessment_count}.sum
        @quest_assessments[strand.abbrev] += @quest_assessments[ls]
        @quest_assessments[level.range] += @quest_assessments[ls]
        @quest_assessments['all'] += @quest_assessments[ls]
        @quest_benchmarks[ls] =  @cell_questions[ls].map{|q| q.benchmark_count}.sum
        @quest_benchmarks[strand.abbrev] += @quest_benchmarks[ls]
        @quest_benchmarks[level.range] += @quest_benchmarks[ls]
        @quest_benchmarks['all'] += @quest_benchmarks[ls]
      end
    end
  end
  def get_level
    if params[:act_score_range_id]
      @current_level = ActScoreRange.find_by_id(params[:act_score_range_id]) rescue nil
    else
      @current_level = nil
    end
  end
  def get_strand
    if params[:act_standard_id]
      @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    else
      @current_strand = nil
    end
  end
end
