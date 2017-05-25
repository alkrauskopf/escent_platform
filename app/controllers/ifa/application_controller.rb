class Ifa::ApplicationController < ApplicationController

  helper :all # include all helpers, all the time
  before_filter :current_ifa_options
  before_filter :set_ifa, :except=>[]
  before_filter :current_app_enabled_for_current_org?, :except=>[]
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_ifa_options
  before_filter :current_standard
  before_filter :clear_notification, :except => []

  def entity_assessment_dashboard(entity, subject, begin_date, end_date)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_milestone = {}
    @cell_achieve = {}
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
          @cell_milestone[hash_key] = @current_student_plan.nil? ? false : @current_student_plan.milestone_for?(level,strand)
          @cell_achieve[hash_key] = @current_student_plan.nil? ? false : @current_student_plan.achieved_for?(level,strand)
        end
      end
    end
  end

  def dashboard_header_info(dashboard, subject, standard)
    @dashboard = {}
    @dashboard['id'] = dashboard.id
    @dashboard['name'] = dashboard.entity_name
    @dashboard['subject'] = subject
    @dashboard['standard'] = standard
    @dashboard['standard_score'] = dashboard.score_for_standard(standard).nil? ? nil : dashboard.score_for_standard(standard).sms_finalized
    @dashboard['sat_score'] = ActScoreRange.sat_score(standard, subject, @dashboard['standard_score'])
    @dashboard['assess_count'] = dashboard.assessments_taken
    @dashboard['answer_count'] = dashboard.finalized_answers
    @dashboard['total_points'] = dashboard.fin_points.nil? ? 0.0 : dashboard.fin_points
    @dashboard['total_duration'] = dashboard.finalized_duration
    @dashboard['proficiency'] = @dashboard['answer_count'] == 0 ? 0 : (100.0 * @dashboard['total_points']/@dashboard['answer_count'].to_f).round
    @dashboard['period_end'] = dashboard.period_end
    @dashboard['efficiency'] = @dashboard['total_points'] == 0.0 ? 0 : (@dashboard['total_duration'].to_f/@dashboard['total_points']).round
  end

  def dashboard_cell_hashes(dashboard, subject, standard)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    @cell_milestone = {}
    @cell_achieve = {}
    if !dashboard.nil? && !subject.nil?
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
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
          @cell_milestone[hash_key] = @current_student_plan.nil? ? nil : @current_student_plan.milestone_for?(level,strand)
          @cell_achieve[hash_key] = @current_student_plan.nil? ? nil : @current_student_plan.achieved_for?(level,strand)
        end
      end
    end
  end
  
  protected

  def current_standard
    @current_standard = ActMaster.default_std
  end

  
end
