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
          @cell_milestone[hash_key] = @current_student_plan.nil? ? false : @current_student_plan.milestone_for?(level,strand)
          @cell_achieve[hash_key] = @current_student_plan.nil? ? false : @current_student_plan.achieved_for?(level,strand)
        end
      end
    end
  end


  protected
  
end
