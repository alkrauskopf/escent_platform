class Ifa::ApplicationController < ApplicationController

  helper :all # include all helpers, all the time
  before_filter :set_ifa, :except=>[]
  before_filter :current_ifa_options
  before_filter :current_app_enabled_for_current_org?, :except=>[]
  before_filter :current_standard

  def current_standard
      @current_standard ||= (params[:act_master_id] ? ActMaster.find_by_id(params[:act_master_id]) : @current_provider.master_standard)
  end

  def current_classroom
    if params[:classroom_id]
      @current_classroom = Classroom.find_by_id(params[:classroom_id]) rescue nil
    end
    current_period
    current_topic
  end

  def current_period
    if params[:period_id]
      @current_classroom_period = ClassroomPeriod.find_by_id(params[:period_id]) rescue nil
    end
  end

  def current_topic
    if params[:topic_id]
      @current_topic = Topic.find_by_id(params[:topic_id]) rescue nil
    else
      @current_topic = @current_classroom.nil? ? nil : (@current_classroom.featured_topic ? @current_classroom.featured_topic : nil)
    end
  end

  def current_subject
    if params[:act_subject_id]
      @current_subject ||= ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    elsif !@current_classroom.nil?
      @current_subject = @current_classroom.act_subject
    else
      @current_subject ||= ActSubject.all_subjects.first
    end
  end

  def ifa_subjects
    @ifa_subjects = ActSubject.all_subjects
  end

  def current_strands(options={})
    @current_strands = ActStandard.active_strands(:subject=>options[:subject], :standard=>options[:standard])
  end

  def current_levels
    @current_levels = @current_subject ? ActScoreRange.active.for_subject(@current_subject) : []
  end

  def question_creators
    @question_creators = ActQuestion.creators
  end

  def assessment_creators
    @assessment_creators = ActAssessment.creators
  end

  def entity_assessment_dashboard(entity, subject, begin_date, end_date)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    if !entity.nil? && !subject.nil? && begin_date
      submissions = end_date ? entity.act_submissions.final_for_subject_window(subject, begin_date, end_date)
      : entity.act_submissions.final_for_subject_since(subject, begin_date)
      @current_standard.act_score_ranges.active.for_subject(subject).each do |level|
        @current_standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          total_points = submissions.collect{|s| s.answer_points(:level=>level, :strand=>strand)}.sum
          total_selected = submissions.collect{|s| s.answers_selected(:level=>level, :strand=>strand)}.sum
          @cell_correct[hash_key] = total_points.to_i
          @cell_total[hash_key] = total_selected
          if total_selected > 0
            @cell_pct[hash_key] = (100.0*(total_points/total_selected.to_f)).to_i
            @cell_color[hash_key] = (@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_red.to_i) ? @current_ifa_options.remedial_color :
                ((@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_green.to_i) ? @current_ifa_options.growth_color :
                    @current_ifa_options.mastery_color)
            @cell_font[hash_key] = (@cell_color[hash_key].to_i < @current_ifa_options.remedial_color.to_i) ? @current_ifa_options.remedial_font :
                (( @cell_color[hash_key].to_i < @current_ifa_options.growth_color.to_i) ? @current_ifa_options.growth_font :
                    @current_ifa_options.mastery_font)
          else
            @cell_pct[hash_key] = 0.0
            @cell_color[hash_key] = @current_ifa_options.empty_cell_color
            @cell_font[hash_key] = @current_ifa_options.empty_cell_font
          end
        end
      end
    end
  end

  def dashboard_header_info(dashboard, subject, standard)
    @dashboard = {}
    if !dashboard.nil?
      @dashboard['id'] = dashboard.id
      @dashboard['name'] = dashboard.entity_name
      @dashboard['subject'] = subject
      @dashboard['standard'] = standard
      @dashboard['standard_score'] = dashboard.score_for_standard(standard).nil? ? nil : dashboard.score_for_standard(standard).standard_score
      @dashboard['sat_score'] = ActScoreRange.sat_score(standard, subject, @dashboard['standard_score'])
      @dashboard['assess_count'] = dashboard.assessments_taken
      @dashboard['answer_count'] = dashboard.finalized_answers
      @dashboard['total_points'] = dashboard.fin_points.nil? ? 0.0 : dashboard.fin_points
      @dashboard['total_duration'] = dashboard.finalized_duration
      @dashboard['proficiency'] = @dashboard['answer_count'] == 0 ? 0 : (100.0 * @dashboard['total_points']/@dashboard['answer_count'].to_f).round
      @dashboard['period_end'] = dashboard.period_end
      @dashboard['efficiency'] = @dashboard['total_points'] == 0.0 ? 0 : (@dashboard['total_duration'].to_f/@dashboard['total_points']).round
    end
  end

  def dashboard_cell_hashes(dashboard, subject, standard, options={})
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_benchmarks = {}
    @cell_suggestions = {}
    @cell_examples = {}
    @cell_evidence = {}
    if !dashboard.nil? && !subject.nil?
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          @cell_benchmarks[hash_key]=standard.active_benches_strand_range(strand, level, ActBenchType.benchmark(standard), options)
          @cell_suggestions[hash_key]=standard.active_benches_strand_range(strand, level, ActBenchType.improvement(standard), options)
          @cell_examples[hash_key]=standard.active_benches_strand_range(strand, level, ActBenchType.example(standard), options)
          @cell_evidence[hash_key]=standard.active_benches_strand_range(strand, level, ActBenchType.evidence(standard), options)
          db_cell = dashboard.cell_for(level, strand)
          if !db_cell.nil?
            total_points = db_cell.fin_points
            total_selected = db_cell.finalized_answers
          else
            total_points = 0.0
            total_selected = 0
          end
          @cell_correct[hash_key] = total_points.to_i
          @cell_total[hash_key] = total_selected
          if total_selected > 0
            @cell_pct[hash_key] = (100.0*(total_points/total_selected.to_f)).to_i
            @cell_color[hash_key] = (@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_red.to_i) ? @current_ifa_options.remedial_color :
                ((@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_green.to_i) ? @current_ifa_options.growth_color :
                    @current_ifa_options.mastery_color)
            @cell_font[hash_key] = (@cell_color[hash_key].to_i < @current_ifa_options.remedial_color.to_i) ? @current_ifa_options.remedial_font :
                (( @cell_color[hash_key].to_i < @current_ifa_options.growth_color.to_i) ? @current_ifa_options.growth_font :
                    @current_ifa_options.mastery_font)
          else
            @cell_pct[hash_key] = 0.0
            @cell_color[hash_key] = @current_ifa_options.empty_cell_color
            @cell_font[hash_key] = @current_ifa_options.empty_cell_font
          end
        end
      end
    end
  end

  def dashboard_milestone_links(user, subject, standard)
    @milestone_links = {}
    plan = user.ifa_plan_for(subject)
    @milestone_links['plan_id'] = plan.nil? ? 0 : plan.id
    @milestone_links['teachers'] = plan.nil? ? [] : plan.relevant_teachers(@current_organization)
    if !subject.nil? && !plan.nil? && @cell_total
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          if (user == @current_user && @cell_total[hash_key] && @cell_total[hash_key] > 0)
            @milestone_links[hash_key] = plan.milestones.open_for_range_strand(level, strand).empty? ? 'Add Milestone' : 'Evidence'
            @milestone_links[hash_key + 'milestone'] = plan.milestone_for_cell(level,strand)
            @milestone_links[hash_key + 'evidence'] = plan.evidences_for_cell(level,strand).size.to_s
          end
        end
      end
    end
  end

  def dashboardable_submissions(dashboard, subject)
    @dashboardable = {}
    if !dashboard.nil? && dashboard.period_end && dashboard.ifa_dashboardable
      @dashboardable['submissions'] = ActSubmission.not_dashboarded(dashboard.ifa_dashboardable_type, dashboard.ifa_dashboardable, subject,
                                    dashboard.period_beginning, dashboard.period_ending)
      @dashboardable['start_date'] = dashboard.period_beginning
      @dashboardable['end_date'] = dashboard.period_ending
      @dashboardable['entity'] = dashboard.ifa_dashboardable
      @dashboardable['subject'] = subject
    end
  end

  def student_assessment_dashboard(submission)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_benchmarks = {}
    @cell_suggestions = {}
    @cell_examples = {}
    @cell_evidence = {}
    if !submission.nil? && !submission.subject.nil?
      @current_standard.act_score_ranges.active.for_subject(submission.subject).each do |level|
        @current_standard.act_standards.active.for_subject(submission.subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          @cell_benchmarks[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.benchmark(@current_standard), :student=>'Y')
          @cell_suggestions[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.improvement(@current_standard), :student=>'Y')
          @cell_examples[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.example(@current_standard), :student=>'Y')
          @cell_evidence[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.evidence(@current_standard), :student=>'Y')
          #         correct_ans = submission.correct_answers(:level=>level, :strand=>strand).size
          #         total_ans = submission.total_answers(:level=>level, :strand=>strand).size
          total_points = submission.answer_points(:level=>level, :strand=>strand)
          total_selected = submission.answers_selected(:level=>level, :strand=>strand)
          @cell_correct[hash_key] = total_points.to_i
          @cell_total[hash_key] = total_selected
          if total_selected > 0
            @cell_pct[hash_key] = (100.0*(total_points/total_selected.to_f)).to_i
            @cell_color[hash_key] = (@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_red.to_i) ? @current_ifa_options.remedial_color :
                ((@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_green.to_i) ? @current_ifa_options.growth_color :
                    @current_ifa_options.mastery_color)
            @cell_font[hash_key] = (@cell_color[hash_key].to_i < @current_ifa_options.remedial_color.to_i) ? @current_ifa_options.remedial_font :
                (( @cell_color[hash_key].to_i < @current_ifa_options.growth_color.to_i) ? @current_ifa_options.growth_font :
                    @current_ifa_options.mastery_font)
          else
            @cell_pct[hash_key] = 0.0
            @cell_color[hash_key] = @current_ifa_options.empty_cell_color
            @cell_font[hash_key] = @current_ifa_options.empty_cell_font
          end
        end
      end
    end
  end

  def assessment_header_info(submission, standard)
    @assessment = {}
    if !submission.nil?
      @assessment['id'] = submission.id
      @assessment['student_name'] = submission.user.nil? ? 'Undefined' : submission.user.first_name
      @assessment['taken_time'] = submission.created_at
      @assessment['standard'] = standard
      @assessment['subject'] = submission.subject
      @assessment['comment'] = submission.student_comment
      @assessment['standard_score'] = submission.sms_score(standard).nil? ? 0 : submission.sms_score(standard)
      @assessment['sat_score'] = ActScoreRange.sat_score(standard, submission.subject, @assessment['standard_score'])
      @assessment['score_status'] = submission.final? ? 'Estimated ' : 'Estimated '
      @assessment['status'] = submission.final? ? 'Final' : 'Pending'
      @assessment['teacher'] = submission.teacher.nil? ? 'Not Identified' : submission.teacher.last_name
      @assessment['answer_count'] = submission.tot_choices.nil? ? 0 : submission.tot_choices
      @assessment['total_points'] = submission.tot_points.nil? ? 0.0 : submission.tot_points.round
      @assessment['duration_secs'] = submission.duration.nil? ? 0 : submission.duration
      @assessment['duration_minutes'] = (@assessment['duration_secs']/60.0).round(1)
      @assessment['answer_rate'] = @assessment['answer_count'] == 0 ? 0 : (@assessment['duration_secs'].to_f/@assessment['answer_count'].to_f).round
      @assessment['proficiency'] = @assessment['answer_count'] == 0 ? 0 : (100.0 * @assessment['total_points']/@assessment['answer_count'].to_f).round
      @assessment['efficiency'] = @assessment['total_points'] == 0.0 ? 0 : (@assessment['duration_secs'].to_f/@assessment['total_points']).round
      if !submission.act_assessment.nil?
        @assessment['title'] = submission.act_assessment.name
        @assessment['question_count'] = submission.act_assessment.questions_for_test.size
        @assessment['best_duration'] = (submission.act_assessment.shortest_duration/60.0).round(1)
        @assessment['best_point_rate'] = submission.act_assessment.best_time_per_point
        @assessment['best_pct'] = submission.act_assessment.best_pct
        @assessment['best_points'] = submission.act_assessment.most_points.round
        @assessment['target_duration'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_submissions.to_f/60.0).round(1)
        @assessment['target_point_rate'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_points_earned).round
        @assessment['target_points'] = (submission.act_assessment.cum_points_earned/submission.act_assessment.cum_submissions.to_f).round
        @assessment['target_pct'] = (100.0 * submission.act_assessment.cum_points_earned/submission.act_assessment.cum_choices_made.to_f).round
        @assessment['target_question_rate'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_questions_asked.to_f).round
        @assessment['target_answer_rate'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_choices_made.to_f).round
        @assessment['target_questions'] = (submission.act_assessment.cum_questions_asked.to_f/submission.act_assessment.cum_submissions.to_f).round
        @assessment['target_answers'] = (submission.act_assessment.cum_choices_made.to_f/submission.act_assessment.cum_submissions.to_f).round
      else
        @assessment['title'] = 'Unknown Assessment'
        @assessment['question_count'] = nil
        @assessment['best_duration'] = nil
        @assessment['best_point_rate'] = nil
        @assessment['best_pct'] = nil
        @assessment['best_points'] = nil
        @assessment['target_duration'] = nil
        @assessment['target_point_rate'] = nil
        @assessment['target_points'] = nil
        @assessment['target_pct'] = nil
        @assessment['target_question_rate'] = nil
        @assessment['target_answer_rate'] = nil
        @assessment['target_questions'] = nil
        @assessment['target_answers'] = nil
      end
    end
  end

  def aggregate_dashboard_cell_hashes(dashboards, subject, standard)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_benchmarks = {}
    @cell_suggestions = {}
    @cell_examples = {}
    @cell_evidence = {}
    student = @current_user.teacher? ? 'N' : 'Y'
    if !dashboards.empty? && !subject.nil?
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          @cell_benchmarks[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.benchmark(@current_standard), :student=>student)
          @cell_suggestions[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.improvement(@current_standard), :student=>student)
          @cell_examples[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.example(@current_standard), :student=>student)
          @cell_evidence[hash_key]=@current_standard.active_benches_strand_range(strand, level, ActBenchType.evidence(@current_standard), :student=>student)
          db_cells = dashboards.collect{|d| d.cell_for(level, strand)}.compact
          if !db_cells.empty?
            total_points = db_cells.collect{|c| c.fin_points}.compact.sum
            total_selected = db_cells.collect{|c| c.finalized_answers}.compact.sum
          else
            total_points = 0.0
            total_selected = 0
          end
          @cell_correct[hash_key] = total_points.to_i
          @cell_total[hash_key] = total_selected
          if total_selected > 0
            @cell_pct[hash_key] = (100.0*(total_points/total_selected.to_f)).to_i
            @cell_color[hash_key] = (@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_red.to_i) ? @current_ifa_options.remedial_color :
                ((@cell_pct[hash_key].to_i < @current_ifa_options.pct_correct_green.to_i) ? @current_ifa_options.growth_color :
                    @current_ifa_options.mastery_color)
            @cell_font[hash_key] = (@cell_color[hash_key].to_i < @current_ifa_options.remedial_color.to_i) ? @current_ifa_options.remedial_font :
                (( @cell_color[hash_key].to_i < @current_ifa_options.growth_color.to_i) ? @current_ifa_options.growth_font :
                    @current_ifa_options.mastery_font)
          else
            @cell_pct[hash_key] = 0.0
            @cell_color[hash_key] = @current_ifa_options.empty_cell_color
            @cell_font[hash_key] = @current_ifa_options.empty_cell_font
          end
        end
      end
    end
  end

  def aggregate_dashboard_header_info(dashboards, subject, standard, entity)
    @aggregate = {}
    @aggregate['entity'] = entity
    @aggregate['subject'] = subject
    @aggregate['standard'] = standard
    @aggregate['assess_count'] = dashboards.collect{|db| db.assessments_taken}.sum
    @aggregate['answer_count'] = dashboards.collect{|db| db.finalized_answers}.sum
    @aggregate['total_points'] = dashboards.collect{|db| db.fin_points}.sum
    @aggregate['total_duration'] = dashboards.collect{|db| db.finalized_duration}.sum
    @aggregate['proficiency'] = @aggregate['answer_count'] == 0 ? 0 : (100.0 * @aggregate['total_points']/@aggregate['answer_count'].to_f).round
    @aggregate['start_period'] = dashboards.empty? ? Date.today : dashboards.sort_by{|d| d.period_end}.first.period_end
    @aggregate['end_period'] = dashboards.empty? ? Date.today : dashboards.sort_by{|d| d.period_end}.last.period_end
    @aggregate['efficiency'] = @aggregate['total_points'] == 0.0 ? 0 : (@aggregate['total_duration'].to_f/@aggregate['total_points']).round
  end

  def assessment_performance(assessment)
    @question_set = {}
    assessment.active_questions.each do |question|
      selected_answers = assessment.act_answers.for_question(question).selected
      points = selected_answers.collect{|a| a.points}.sum rescue 0
      selection_count = selected_answers.size
      @question_set['points' + question.id.to_s] = points.to_i
      @question_set['selections' + question.id.to_s] = selection_count
      @question_set['proficiency' + question.id.to_s] = selection_count == 0 ? nil : (100.0*points/selection_count.to_f).to_i
      @question_set['seq_score' + question.id.to_s] = question.sequence_score_for(@current_standard, 'PP')
      @question_set['align_score' + question.id.to_s] = question.alignment_score_for(@current_standard, 'PP')
    end
  end

  def classroom_pools(assessments)
    @classroom_set = {}
    assessments.each do |ass|
      @classroom_set['pool'+ ass.id.to_s] = @current_organization == @current_provider ? (Classroom.for_subject(ass.act_subject).precision_prep_provider(@current_provider)) :
        @current_organization.classrooms.for_subject(ass.act_subject).select{|c| c.ifa_enabled?}
      @classroom_set['available'+ ass.id.to_s] = @classroom_set['pool'+ ass.id.to_s] - ass.classrooms
      @classroom_set['used'+ ass.id.to_s] = ass.classrooms
    end
  end

  def classroom_pool(ass)
    @classroom_set = {}
      @classroom_set['pool'+ ass.id.to_s] = @current_organization == @current_provider ? (Classroom.for_subject(ass.act_subject).precision_prep_provider(@current_provider)) :
          @current_organization.classrooms.for_subject(ass.act_subject).select{|c| c.ifa_enabled?}
      @classroom_set['available'+ ass.id.to_s] = @classroom_set['pool'+ ass.id.to_s] - ass.classrooms
      @classroom_set['used'+ ass.id.to_s] = ass.classrooms
  end

  def dashboard_plan_markers(dashboard, subject, standard)
    entity = dashboard.ifa_dashboardable rescue nil
      if !entity.nil?
      metric = entity.ifa_plan_metrics.metric_table(subject)
      @plan_markers = {}
      @plan_markers['w_total']=metric.metrics.in_cell('total').in_process rescue 0
      @plan_markers['a_total']=metric.metrics.in_cell('total').achieved rescue 0
      if !subject.nil?
        standard.act_standards.active.for_subject(subject).each do |strand|
          @plan_markers['w_tot_s' + strand.id.to_s]=metric.metrics.in_cell('strand'+ strand.id.to_s).in_process rescue 0
          @plan_markers['a_tot_s' + strand.id.to_s]=metric.metrics.in_cell('strand'+ strand.id.to_s).achieved rescue 0
        end
        standard.act_score_ranges.active.for_subject(subject).each do |level|
          @plan_markers['w_tot_l' + level.id.to_s]=metric.metrics.in_cell('level'+ level.id.to_s).in_process rescue 0
          @plan_markers['a_tot_l' + level.id.to_s]=metric.metrics.in_cell('level'+ level.id.to_s).achieved rescue 0
          standard.act_standards.active.for_subject(subject).each do |strand|
            hash_key = level.id.to_s + strand.id.to_s
            @plan_markers['w'+hash_key] = metric.metrics.in_cell(level.id.to_s + '|' + strand.id.to_s).in_process rescue 0
            @plan_markers['a'+hash_key] = metric.metrics.in_cell(level.id.to_s + '|' + strand.id.to_s).achieved rescue 0
          end
        end
      end
    end
  end

  def dashboard_plan_markers_old(users, subject, standard)
    @plan_markers = {}
    @plan_markers['w_total']=0
    @plan_markers['a_total']=0
    if !users.empty? && !subject.nil?
      standard.act_standards.active.for_subject(subject).each do |strand|
        @plan_markers['w_tot_s' + strand.id.to_s]=0
        @plan_markers['a_tot_s' + strand.id.to_s]=0
      end
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        @plan_markers['w_tot_l' + level.id.to_s]=0
        @plan_markers['a_tot_l' + level.id.to_s]=0
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          @plan_markers['w'+hash_key] = 0
          @plan_markers['a'+hash_key] = 0
         # users.map{ |u| (u.ifa_plans.empty? ? []: u.ifa_plans.for_subject(subject))}.flatten.compact.each do |plan|
          users.map{ |u| (u.ifa_plan_for(subject).nil? ? nil : u.ifa_plan_for(subject))}.flatten.compact.each do |plan|
            @plan_markers['w'+hash_key] += plan.milestones.open_for_range_strand(level, strand).size
            @plan_markers['a'+hash_key] += plan.milestones.achieved_for_range_strand(level, strand).size
            @plan_markers['w_tot_s' + strand.id.to_s] += plan.milestones.open_for_range_strand(level, strand).size
            @plan_markers['a_tot_s' + strand.id.to_s] += plan.milestones.achieved_for_range_strand(level, strand).size
            @plan_markers['w_tot_l' + level.id.to_s] += plan.milestones.open_for_range_strand(level, strand).size
            @plan_markers['a_tot_l' + level.id.to_s] += plan.milestones.achieved_for_range_strand(level, strand).size
            @plan_markers['w_total'] += plan.milestones.open_for_range_strand(level, strand).size
            @plan_markers['a_total'] += plan.milestones.achieved_for_range_strand(level, strand).size
          end
        end
      end
    end
  end

  def dashboard_users(dashboard)
    entity = dashboard.ifa_dashboardable
    users = []
    if entity.class.to_s == 'Organization'
      users << entity.ifa_students(dashboard.act_subject)
    elsif entity.class.to_s == 'Classroom'
      users << entity.students
    elsif entity.class.to_s == 'User'
      users << entity
    end
    users.flatten
  end

  protected
  
end
