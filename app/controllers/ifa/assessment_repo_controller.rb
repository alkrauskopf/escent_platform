class Ifa::AssessmentRepoController < Ifa::ApplicationController

    layout "ifa_repo", :except=>[:assessment_list]

    before_filter :current_user_app_authorized?
    before_filter :current_user_app_admin?, :only=>[]
    before_filter :current_app_superuser
    before_filter :current_user_app_admin
    before_filter :current_subject, :except => [:index]
    before_filter :clear_notification, :except => []

    def index
      ifa_subjects
      if params[:act_subject] && params[:act_subject][:id] && params[:act_subject][:id] != ''
        @current_subject = ActSubject.find_by_id(params[:act_subject][:id]) rescue ActSubject.all_subjects.first
      else
        current_subject
      end
      @function = 'Create'
      @current_assessment = ActAssessment.new
    end

    def question_position_update
      get_current_assessment
      get_current_question
      if params[:position] && params[:position].to_i > 0
        if !@current_assessment.question_joins(@current_question).first.nil?
          @current_assessment.question_joins(@current_question).first.update_attributes(:position => params[:position].to_i)
        end
      end
      question_pool
      render :partial =>  "assessment_questions"
    end

    def pool_filter
      get_current_assessment
      question_pool
      render :partial =>  "question_pool"
    end

    def toggle_add_question
      get_current_assessment
      get_current_question
      if @current_assessment.act_questions.include?(@current_question)
        @current_assessment.question_joins(@current_question).destroy_all
      elsif
        question_join = ActAssessmentActQuestion.new
        question_join.act_question_id = @current_question.id
        question_join.position = @current_assessment.act_questions.size + 1
        @current_assessment.act_assessment_act_questions << question_join
      end
      calibrate_assessment
      question_pool
      render :partial =>  "assessment_questions"
    end

    def refresh
      get_current_assessment
      calibrate_assessment
      question_pool
      render :partial =>  "assessment_questions"
    end

    def toggle_active
      get_current_assessment
      if params[:function] == 'Active'
        @current_assessment.update_attributes(:is_active => !@current_assessment.is_active)
      elsif params[:function] == 'Lock'
        @current_assessment.update_attributes(:is_locked => !@current_assessment.is_locked)
      elsif params[:function] == 'Strategy'
        @current_assessment.update_attributes(:is_strategy_test => !@current_assessment.is_strategy_test)
      end
      render :partial =>  "assessment_buttons"
    end

    def create
      ifa_subjects
      if function == 'Create'
        @current_assessment = ActAssessment.new
      else
        get_current_assessment
      end
      if !@current_assessment.nil?
        update_assessment
        question_pool
      else
        flash[:error] = 'Could Not Create Assessment Object'
      end
      render :index
    end

    def assessment_list
      assessment_pool
      classroom_pools(@entity_assessments)
      current_strands(:standard=>@current_standard)
      render :partial =>  "assessment_list"
    end

    def classroom_assign
      get_current_assessment
      get_current_classroom
      if !@current_assessment.classrooms.include?(@current_classroom)
        @current_assessment.add_classroom(@current_classroom)
      else
        @current_assessment.remove_classroom(@current_classroom)
      end
      get_current_assessment
      classroom_pool(@current_assessment)
      render :partial => "assessment_classrooms", :locals => {:assessment => @current_assessment}
    end

    def edit
      get_current_assessment
      ifa_subjects
      question_pool
      @function = 'Update'
      render :index
    end

    def destroy
      get_current_assessment
      @current_assessment.destroy
      assessment_pool
      classroom_pools(@entity_assessments)
      assessment_creators
      current_strands(:standard=>@current_standard)
      render :partial =>  "assessment_list"
    end

    def static_assessment
      get_current_assessment
      assessment_classrooms
      assessment_performance(@current_assessment)
    end

    private

    def function
      @function = params[:function] ? params[:function]: nil
      @function
    end

    def pool_filters
      @user_filters = @current_subject.act_questions.collect{|q| q.user}.compact.uniq
      @level_filters = @current_standard.mastery_levels(@current_subject)
      @strand_filters = @current_standard.strands(@current_subject)
    end

    def question_pool
      @user_filter = User.find_by_id(params[:filter_user_id]) rescue nil
      @level_filter = ActScoreRange.find_by_id(params[:filter_level_id]) rescue nil
      @strand_filter = ActStandard.find_by_id(params[:filter_strand_id]) rescue nil
      @assessment_questions = @current_assessment.active_questions
      @question_pool = @current_subject.available_questions(@user_filter, @level_filter, @strand_filter) - @assessment_questions
      pool_filters
    end

    def calibrate_assessment
      get_current_assessment
      @current_assessment.reconstitute
      get_current_assessment
    end

    def get_current_assessment
      if params[:act_assessment_id]
        @current_assessment = ActAssessment.find_by_id(params[:act_assessment_id]) rescue nil
      end
    end

    def get_current_classroom
      if params[:classroom_id]
        @current_classroom = Classroom.find_by_id(params[:classroom_id]) rescue nil
      end
    end

    def assessment_classrooms
      @assessment_classrooms = @current_assessment.act_submissions.collect{|s| s.classroom}.compact.uniq
    end

    def get_current_question
      if params[:act_question_id]
        @current_question = ActQuestion.find_by_id(params[:act_question_id]) rescue nil
      end
    end

    def update_assessment
      @current_assessment.name = params[:act_assessment][:name]
      @current_assessment.comment = params[:act_assessment][:comment]
      @current_assessment.organization_id = @current_organization.id
      @current_assessment.user_id = @current_user.id
      if @current_subject.act_assessments << @current_assessment
        flash[:notice] = "#{@current_assessment.name} Assessment #{function} Successful"
        @function = 'Update'
      else
        flash[:error] = @current_assessment.errors.full_messages.to_sentence
      end
    end

    def get_entity
      if params[:entity_class] && params[:entity_class] == 'User'
        @current_entity = User.find_by_id(params[:entity_id]) rescue nil
      elsif params[:entity_class] && params[:entity_class] == 'ActStandard'
        @current_entity = ActStandard.find_by_id(params[:entity_id]) rescue nil
      else
        @current_entity = nil
      end
    end

    def assessment_pool
      if params[:entity_id] && params[:entity_id] == '0'
        @entity_assessments = ActAssessment.empties
      else
        get_entity
        @entity_assessments = @current_entity.act_assessments
      end
      assessment_creators
      current_strands(:standard=>@current_standard)
    end
  end