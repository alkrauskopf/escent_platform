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

    def toggle_active
      get_current_assessment
      if params[:function] == 'Active'
        @current_assessment.update_attributes(:is_active => !@current_assessment.is_active)
      elsif params[:function] == 'Lock'
        @current_assessment.update_attributes(:is_locked => !@current_assessment.is_locked)
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
      @assessment_questions = @current_assessment.all_questions
      @question_pool = @current_subject.available_questions(@user_filter, @level_filter, @strand_filter) - @assessment_questions
      pool_filters
    end

    def calibrate_assessment
      get_current_assessment
      upper_score = @current_assessment.max_question_level.nil? ? 0 : @current_assessment.max_question_level.upper_score
      lower_score = @current_assessment.min_question_level.nil? ? 0 : @current_assessment.min_question_level.lower_score
      @current_assessment.update_attributes(:lower_level_id => (@current_assessment.min_question_level.nil? ? nil : @current_assessment.min_question_level.id),
      :upper_level_id => (@current_assessment.max_question_level.nil? ? nil : @current_assessment.max_question_level.id),
      :min_score => lower_score, :max_score => upper_score, :is_calibrated => @current_assessment.questions_calibrated?,
      :original_assessment_id => (@current_assessment.original_assessment_id.nil? ? @current_assessment.id : @current_assessment.original_assessment_id))
    end

    def get_current_assessment
      if params[:act_assessment_id]
        @current_assessment = ActAssessment.find_by_id(params[:act_assessment_id]) rescue nil
      end
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
  end