class Apps::ApplicationController < ApplicationController

  helper :all # include all helpers, all the time
  layout "site"

  def student_assessment_dashboard(submission)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_milestone = {}
    @cell_achieve = {}
    if !submission.nil? && !submission.subject.nil?
      @current_standard.act_score_ranges.active.for_subject(submission.subject).each do |level|
        @current_standard.act_standards.active.for_subject(submission.subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
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
          @cell_milestone[hash_key] = @current_student_plan.nil? ? nil : @current_student_plan.milestone_for?(level,strand)
          @cell_achieve[hash_key] = @current_student_plan.nil? ? nil : @current_student_plan.achieved_for?(level,strand)
        end
      end
    end
  end

  def assessment_header_info(submission, standard)
    @assessment = {}
    if !submission.nil?
      @assessment['id'] = submission.id
      @assessment['taken_time'] = submission.created_at
      @assessment['standard'] = standard
      @assessment['subject'] = submission.subject
      @assessment['comment'] = submission.student_comment
      @assessment['standard_score'] = submission.sms_score(standard).nil? ? 0 : submission.sms_score(standard)
      @assessment['sat_score'] = ActScoreRange.sat_score(standard, submission.subject, @assessment['standard_score'])
      @assessment['score_status'] = submission.final? ? '' : 'Estimated '
      @assessment['status'] = submission.final? ? 'Final' : 'Pending'
      @assessment['teacher'] = submission.teacher.nil? ? 'Not Identified' : submission.teacher.last_name
      @assessment['answer_count'] = submission.tot_choices.nil? ? 0 : submission.tot_choices
      @assessment['total_points'] = submission.tot_points.nil? ? 0.0 : submission.tot_points
      @assessment['duration_secs'] = submission.duration.nil? ? 0 : submission.duration
      @assessment['duration_minutes'] = @assessment['duration_secs']/60.0
      @assessment['proficiency'] = @assessment['answer_count'] == 0 ? 0 : (100.0 * @assessment['total_points']/@assessment['answer_count'].to_f).round
      @assessment['efficiency'] = @assessment['total_points'] == 0.0 ? 0 : (@assessment['duration_secs'].to_f/@assessment['total_points']).round
    end
  end

  def aggregate_dashboard_cell_hashes(dashboards, subject, standard)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_milestone = {}
    @cell_achieve = {}
    if !dashboards.empty? && !subject.nil?
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
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

  protected
  
end
