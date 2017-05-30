class AppMaintenance::ApplicationController < ApplicationController

  before_filter :set_ifa, :except=>[]
  before_filter :current_ifa_options

  def demo_dash_hashes(dashboard, subject, standard)
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    @cell_color = {}
    @cell_font = {}
    if !subject.nil? && !standard.nil?
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          db_cell = dashboard.nil? ? nil : dashboard.cell_for(level, strand)
          if !db_cell.nil?
            total_points = db_cell.fin_points
            total_selected = db_cell.finalized_answers
          else
            total_points = 0.0
            total_selected = 0
          end
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
          @cell_correct[hash_key] = total_points.to_i
          @cell_total[hash_key] = total_selected
        end
      end
    end
  end

  def orig_user_db_cells(dashboard_new, subject, standard)
    @orig_cell_correct = {}
    @orig_cell_total = {}
    @orig_dashboard = {}
    @orig_dashboard['assessments_taken'] = dashboard_new.assessments_taken
    @orig_dashboard['finalized_assessments'] = dashboard_new.finalized_assessments
    @orig_dashboard['calibrated_assessments'] = dashboard_new.calibrated_assessments
    @orig_dashboard['finalized_duration'] = dashboard_new.finalized_duration
    @orig_dashboard['calibrated_duration'] = dashboard_new.calibrated_duration
    @orig_dashboard['finalized_answers'] = dashboard_new.finalized_answers
    @orig_dashboard['fin_points'] = dashboard_new.fin_points
    @orig_dashboard['calibrated_answers'] = dashboard_new.calibrated_answers
    @orig_dashboard['cal_points'] = dashboard_new.cal_points
    @orig_dashboard['cal_submission_points'] = dashboard_new.cal_submission_points
    @orig_dashboard['cal_submission_answers'] = dashboard_new.cal_submission_answers
    @orig_dashboard['calibrated_duration'] = dashboard_new.calibrated_duration

    if !subject.nil? && !standard.nil?
      standard.act_score_ranges.active.for_subject(subject).each do |level|
        standard.act_standards.active.for_subject(subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          @orig_cell_correct[hash_key] = dashboard_new.cell_for(level, strand).nil? ? 0.0 : dashboard_new.cell_for(level, strand).fin_points
          @orig_cell_total[hash_key] = dashboard_new.cell_for(level, strand).nil? ? 0 : dashboard_new.cell_for(level, strand).finalized_answers
        end
      end
    end
  end


  def dashboard_deltas(dashboard_new, subject, standard)
    @dashboard_deltas = {}
    @cell_deltas = {}

    @dashboard_deltas['assessments_taken'] = dashboard_new.assessments_taken - @orig_dashboard['assessments_taken']
    @dashboard_deltas['finalized_assessments'] = dashboard_new.finalized_assessments - @orig_dashboard['finalized_assessments']
    @dashboard_deltas['calibrated_assessments'] = dashboard_new.calibrated_assessments - @orig_dashboard['calibrated_assessments']
    @dashboard_deltas['finalized_duration'] = dashboard_new.finalized_duration - @orig_dashboard['finalized_duration']
    @dashboard_deltas['calibrated_duration'] = dashboard_new.calibrated_duration - @orig_dashboard['calibrated_duration']
    @dashboard_deltas['finalized_answers'] = dashboard_new.finalized_answers - @orig_dashboard['finalized_answers']
    @dashboard_deltas['fin_points'] = dashboard_new.fin_points - @orig_dashboard['fin_points']
    @dashboard_deltas['calibrated_answers'] = dashboard_new.calibrated_answers - @orig_dashboard['calibrated_answers']
    @dashboard_deltas['cal_points'] = dashboard_new.cal_points - @orig_dashboard['cal_points']
    @dashboard_deltas['cal_submission_points'] = dashboard_new.cal_submission_points - @orig_dashboard['cal_submission_points']
    @dashboard_deltas['cal_submission_answers'] = dashboard_new.cal_submission_answers - @orig_dashboard['cal_submission_answers']
    @dashboard_deltas['calibrated_duration'] = dashboard_new.calibrated_duration - @orig_dashboard['calibrated_duration']

    standard.act_score_ranges.active.for_subject(subject).each do |level|
      standard.act_standards.active.for_subject(subject).each do |strand|
        hash_key = level.id.to_s + strand.id.to_s
        new_cell = dashboard_new.cell_for(level,strand)
        @cell_deltas[hash_key +'finalized_answers'] = (new_cell.nil? ? 0 : new_cell.finalized_answers) - @orig_cell_total[hash_key]
        @cell_deltas[hash_key +'calibrated_answers'] = (new_cell.nil? ? 0 : new_cell.calibrated_answers) - @orig_cell_total[hash_key]
        @cell_deltas[hash_key +'fin_points'] = (new_cell.nil? ? 0.0 : new_cell.fin_points) - @orig_cell_correct[hash_key]
        @cell_deltas[hash_key +'cal_points'] = (new_cell.nil? ? 0.0 : new_cell.cal_points) - @orig_cell_correct[hash_key]
        @cell_deltas[hash_key + 'changed'] = !((@cell_deltas[hash_key +'finalized_answers'] == 0) &&
          (@cell_deltas[hash_key +'fin_points'] == 0.0) &&
          (@cell_deltas[hash_key +'calibrated_answers'] == 0.0) &&
          (@cell_deltas[hash_key +'cal_points'] == 0.0))
      end
    end
  end
  protected
end
