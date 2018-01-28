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

  def dashboard_header_info_old(dashboard, subject, standard)
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
    header = {}
    header['type'] = 'assessment'
    if !submission.nil?
      header['submission'] = submission
      header['entity_name'] = submission.user.nil? ? 'Undefined' : submission.user.first_name
      header['taken_time'] = submission.created_at
      header['standard'] = standard
      header['std_abbrev'] = standard.abbrev
      header['subject'] = submission.subject
      header['comment'] = submission.student_comment
      header['standard_score'] = submission.sms_score(standard).nil? ? '0' : submission.sms_score(standard)
      header['sat_score'] = ActScoreRange.sat_score(standard, submission.subject, header['standard_score'])
      header['score_status'] = submission.final? ? 'Est.' : 'Est.'
      header['submission_status'] = submission.final? ? 'Final' : 'Pending'
      header['teacher'] = submission.teacher.nil? ? 'Unkown Teacher' : submission.teacher.last_name
      header['answer_count'] = submission.tot_choices.nil? ? 0 : submission.tot_choices
      header['total_points'] = submission.tot_points.nil? ? 0.0 : submission.tot_points.round
      header['duration_secs'] = submission.duration.nil? ? 0 : submission.duration
      header['duration_minutes'] = (header['duration_secs']/60.0).round(1)
      header['question_pace'] = submission.question_pace
      header['proficiency'] = header['answer_count'] == 0 ? 0 : (100.0 * header['total_points']/header['answer_count'].to_f).round
      header['point_pace'] = header['total_points'] == 0.0 ? 0 : (header['duration_secs'].to_f/header['total_points']).round
      if !submission.act_assessment.nil?
        header['assess_title'] = submission.act_assessment.name
        header['assessment'] = submission.act_assessment
        header['total_questions'] = submission.act_assessment.questions_for_test.size
        header['best_duration'] = (submission.act_assessment.shortest_duration/60.0).round(1)
        header['best_point_pace'] = submission.act_assessment.best_time_per_point
        header['best_proficiency'] = submission.act_assessment.best_pct
        header['best_points'] = submission.act_assessment.most_points.round
        header['best_question_pace'] = submission.act_assessment.best_answer_rate
        header['best_answered'] = submission.act_assessment.most_answered
        header['pop_duration'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_submissions.to_f/60.0).round(1)
        header['pop_point_pace'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_points_earned).round
        header['pop_points'] = (submission.act_assessment.cum_points_earned/submission.act_assessment.cum_submissions.to_f).round
        header['pop_proficiency'] = (100.0 * submission.act_assessment.cum_points_earned/submission.act_assessment.cum_choices_made.to_f).round
        header['pop_question_pace'] = (submission.act_assessment.cum_duration.to_f/submission.act_assessment.cum_choices_made.to_f).round
        header['pop_answers'] = (submission.act_assessment.cum_choices_made.to_f/submission.act_assessment.cum_submissions.to_f).round
        header['target_question_pace'] = submission.act_assessment.question_pace
        header['target_duration'] = (submission.act_assessment.allotted_duration.to_f/60.0).round(1)
      else
        header['assess_title'] = nil
        header['assessment'] = nil
        header['total_questions'] = nil
        header['best_duration'] = nil
        header['best_point_pace'] = nil
        header['best_proficiency'] = nil
        header['best_points'] = nil
        header['best_question_pace'] = nil
        header['best_answered'] = nil
        header['pop_duration'] = nil
        header['pop_point_pace'] = nil
        header['pop_points'] = nil
        header['pop_proficiency'] = nil
        header['pop_question_pace'] = nil
        header['pop_answers'] = nil
        header['target_question_pace'] = nil
        header['target_duration'] = nil
      end
      dashboard_header_rows(header)
    end
  end

  def entity_header_info(dashboard, subject, standard)
    header = {}
    header['type'] = 'entity'
    if !dashboard.nil?
      header['entity_class'] = dashboard.ifa_dashboardable_type
      header['dashboard'] = dashboard
      header['last_updated'] = dashboard.updated_at
      header['name'] = dashboard.entity_name
      header['subject'] = subject
      header['standard'] = standard
      header['std_abbrev'] = standard.abbrev
      header['standard_score'] = dashboard.score_for_standard(standard).nil? ? nil : dashboard.score_for_standard(standard).standard_score
      header['sat_score'] = ActScoreRange.sat_score(standard, subject, header['standard_score'])
      header['assess_count'] = dashboard.assessments_taken
      header['answer_count'] = dashboard.finalized_answers
      header['total_points'] = dashboard.fin_points.nil? ? 0.0 : dashboard.fin_points
      header['total_duration'] = dashboard.finalized_duration
      header['proficiency'] = header['answer_count'] == 0 ? 0 : (100.0 * header['total_points']/header['answer_count'].to_f).round
      header['period_end'] = dashboard.period_end
      header['efficiency'] = header['total_points'] == 0.0 ? 0 : (header['total_duration'].to_f/header['total_points']).round
    end
    dashboard_header_rows(header)
  end

  def aggregate_header_info(dashboards, subject, standard, entity)
    header = {}
    header['type'] = 'aggregate'
    header['entity'] = entity
    header['name'] = entity.name
    header['entity_class'] = entity.class.to_s
    header['subject'] = subject
    header['standard'] = standard
    header['assess_count'] = dashboards.collect{|db| db.assessments_taken}.sum
    header['answer_count'] = dashboards.collect{|db| db.finalized_answers}.sum
    header['total_points'] = dashboards.collect{|db| db.fin_points}.sum
    header['total_duration'] = dashboards.collect{|db| db.finalized_duration}.sum
    header['proficiency'] = header['answer_count'] == 0 ? 0 : (100.0 * header['total_points']/header['answer_count'].to_f).round
    header['start_period'] = dashboards.empty? ? Date.today : dashboards.sort_by{|d| d.period_end}.first.period_end
    header['end_period'] = dashboards.empty? ? Date.today : dashboards.sort_by{|d| d.period_end}.last.period_end
    header['efficiency'] = header['total_points'] == 0.0 ? 0 : (header['total_duration'].to_f/header['total_points']).round
    dashboard_header_rows(header)
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
  def student_test_prep_stats(students, subject, standard)
    @test_prep_stats = []
    students.each do |student|
      stat_row = {}
      stat_row['name'] = student.last_name_first
      stat_row['break'] = true
      stat_row['ass_taken'] = student.assessments_taken(:subject => subject).size
      @test_prep_stats << stat_row
      student.assessments_taken(:subject => subject).each do |sub|
        stat_row = {}
        stat_row['break'] = false
        stat_row['name'] = student.first_name
        stat_row['assessment_name'] = sub.act_assessment.nil? ? 'Assessment Undefined' : sub.act_assessment.name
        stat_row['date'] = sub.created_at
        stat_row['score'] = sub.sms_score(standard)
        stat_row['sat_score'] = ActScoreRange.sat_score(standard, subject, stat_row['score'])
        stat_row['score'] = sub.tot_choices
        stat_row['total_points'] = sub.tot_points.nil? ? 0.0.round : sub.tot_points.round
        stat_row['answer_count'] = sub.tot_choices.nil? ? 0 : sub.tot_choices
        stat_row['question_count'] = sub.act_assessment.nil? ? 0 : sub.act_assessment.questions_for_test.size
        stat_row['proficiency'] = stat_row['answer_count'] == 0 ? 0 : (100.0 * stat_row['total_points']/stat_row['answer_count'].to_f).round
        stat_row['duration_secs'] = sub.duration.nil? ? 0 : sub.duration
        stat_row['duration_minutes'] = (stat_row['duration_secs']/60.0).round(1)
        stat_row['answer_rate'] = stat_row['answer_count'] == 0 ? 0 : (stat_row['duration_secs'].to_f/stat_row['answer_count'].to_f).round
        stat_row['point_rate'] = stat_row['total_points'] == 0.0 ? 0 : (stat_row['duration_secs'].to_f/stat_row['total_points']).round
        if !sub.act_assessment.nil? && sub.act_assessment.cum_submissions > 0
          stat_row['target_points'] = (sub.act_assessment.cum_points_earned.to_f/sub.act_assessment.cum_submissions.to_f).round
          stat_row['target_pct'] =  (100.0 * sub.act_assessment.cum_points_earned.to_f/sub.act_assessment.cum_choices_made.to_f).round
          stat_row['target_answers'] = (sub.act_assessment.cum_choices_made.to_f/sub.act_assessment.cum_submissions.to_f).round
          stat_row['target_duration'] = (sub.act_assessment.cum_duration.to_f/sub.act_assessment.cum_submissions.to_f/60.0).round(1)
          stat_row['target_point_rate'] = (sub.act_assessment.cum_duration.to_f/sub.act_assessment.cum_points_earned.to_f).round
          stat_row['target_answer_rate'] = (sub.act_assessment.cum_duration.to_f/sub.act_assessment.cum_choices_made.to_f).round
        else
          stat_row['target_points'] = 0
          stat_row['target_pct'] =  0
          stat_row['target_answers'] = 0
          stat_row['target_duration'] = 0
          stat_row['target_point_rate'] = 0
          stat_row['target_answer_rate'] = 0

        end
          @test_prep_stats << stat_row
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

  def dashboard_header_rows(header)
    @dashboard_header = {}
    @dashboard_header['type'] = header['type']
    if header['type'] == 'assessment'
      @dashboard_header['db_type'] = header['assessment'].nil? ? '' : (header['assessment'].test_strategies? ? 'Test Strategies' : 'Needs Diagnostic')
      @dashboard_header['row1'] = header['assess_title']
      @dashboard_header['taken_time'] = header['taken_time']
      @dashboard_header['row1_scores'] =  header['score_status'] + ' SAT ' + header['sat_score'].to_s + ', ' +
          header['std_abbrev'] + ' ' + header['standard_score'].to_s
      @dashboard_header['row1_right'] =header['teacher']
      @dashboard_header['table_0'] = []
      @dashboard_header['table_1'] = []
      @dashboard_header['table_2'] = []
      @dashboard_header['table_3'] = []
      @dashboard_header['table_4'] = []
      @dashboard_header['table_5'] = []
      @dashboard_header['table_glyph'] = []
      @dashboard_header['table_0'] << ''
      @dashboard_header['table_1'] << header['entity_name']
      @dashboard_header['table_2'] << 'Target'
      @dashboard_header['table_3'] << 'Others'
      @dashboard_header['table_4'] << 'Best'
      @dashboard_header['table_5'] << ''
      @dashboard_header['table_glyph'] << ''
      @dashboard_header['table_0'] << 'Duration (Mins)'
      @dashboard_header['table_1'] << header['duration_minutes']
      @dashboard_header['table_2'] << header['target_duration']
      @dashboard_header['table_3'] << header['pop_duration']
      @dashboard_header['table_4'] << header['best_duration']
      @dashboard_header['table_5'] << ''
      @dashboard_header['table_glyph'] << (header['duration_minutes'] > header['target_duration'] ? 'orange_exclaim' : 'green_star')
      @dashboard_header['table_0'] << 'Answers'
      @dashboard_header['table_1'] << header['answer_count']
      @dashboard_header['table_2'] << header['total_questions']
      @dashboard_header['table_3'] << header['pop_answers']
      @dashboard_header['table_4'] << header['best_answered']
      @dashboard_header['table_5'] << ''
      @dashboard_header['table_glyph'] << (header['answer_count'] < header['total_questions'] ? 'orange_exclaim' : 'green_star')
      @dashboard_header['table_0'] << '% Correct'
      @dashboard_header['table_1'] << header['proficiency'].to_s + '%'
      @dashboard_header['table_2'] << ''
      @dashboard_header['table_3'] << header['pop_proficiency'].to_s + '%'
      @dashboard_header['table_4'] << header['best_proficiency'].to_s + '%'
      @dashboard_header['table_5'] << ''
      @dashboard_header['table_glyph'] << ''
      @dashboard_header['table_0'] << 'Question Pace'
      @dashboard_header['table_1'] << header['question_pace']
      @dashboard_header['table_2'] << header['target_question_pace']
      @dashboard_header['table_3'] << header['pop_question_pace']
      @dashboard_header['table_4'] << header['best_question_pace']
      @dashboard_header['table_5'] << 'Seconds per Question'
      @dashboard_header['table_glyph'] << (header['question_pace'] > header['target_question_pace'] ? 'orange_exclaim' : 'green_star')
      @dashboard_header['table_0'] << 'Proficiency Pace'
      @dashboard_header['table_1'] << header['point_pace']
      @dashboard_header['table_2'] << ''
      @dashboard_header['table_3'] << header['pop_point_pace']
      @dashboard_header['table_4'] << header['best_point_pace']
      @dashboard_header['table_5'] << 'Seconds per Correct Answer'
      @dashboard_header['table_glyph'] << ''
      if !header['assessment'].nil? && header['assessment'].test_strategies?
        @dashboard_header['strat_0'] = []
        @dashboard_header['strat_1'] = []
        @dashboard_header['strat_2'] = []
        @dashboard_header['strat_3'] = []
        @dashboard_header['strat_4'] = []
        @dashboard_header['strat_0'][0] = '<br/>Strategy'
        @dashboard_header['strat_1'][0] = '<br/>Used'
        @dashboard_header['strat_2'][0] = 'Preferred<br/>Used'
        @dashboard_header['strat_3'][0] = 'Correct</br>Answers'
        @dashboard_header['strat_4'][0] = ''
        header['submission'].act_strategy_logs.each do |log|
          @dashboard_header['strat_0'] << log.act_strategy.name
          @dashboard_header['strat_1'] << log.use_count.to_s
          @dashboard_header['strat_2'] << log.matches.to_s
          @dashboard_header['strat_3'] << (log.use_count == 0 ? '-' : ((100.0 * log.corrects.to_f/log.use_count.to_f).round.to_s + '%'))
          @dashboard_header['strat_4'] << ''
        end
      end

    elsif header['type'] == 'entity'
      @dashboard_header['db_type'] = header['entity_class']
      @dashboard_header['row1'] =   header['name'] + ' | ' + header['subject'].name  + ' | '
      @dashboard_header['taken_time'] = header['last_updated']
      @dashboard_header['row1_scores'] =  ' SAT ' + header['sat_score'].to_s + ', ' +
          header['std_abbrev'] + ' ' + header['standard_score'].to_s

    elsif header['type'] == 'aggregate'
      @dashboard_header['db_type'] = header['entity_class']
      @dashboard_header['row1'] =   header['name'] + ' | ' + header['subject'].name
      @dashboard_header['taken_time'] = header['start_period']
      @dashboard_header['row1_scores'] =  ''
      @dashboard_header['start_period'] = header['start_period']
      @dashboard_header['end_period'] = header['end_period']
      @dashboard_header['entity'] = header['entity']
      @dashboard_header['subject'] = header['subject']
      @dashboard_header['proficiency'] = header['proficiency']
      @dashboard_header['efficiency'] = header['efficiency']
      @dashboard_header['total_points'] = header['total_points']
      @dashboard_header['answer_count'] = header['answer_count']
      @dashboard_header['assess_count'] = header['assess_count']
    end
  end
  
end
