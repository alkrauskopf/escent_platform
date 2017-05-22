class Apps::ApplicationController < ApplicationController

  helper :all # include all helpers, all the time
  layout "site"

  def student_assessment_dashboard(submission)
    @cell_correct = {}
    @cell_total = {}
    @cell_correct = {}
    @cell_pct = {}
    if !submission.nil? && !submission.subject.nil?
      @current_standard.act_score_ranges.active.for_subject(submission.subject).each do |level|
        @current_standard.act_standards.active.for_subject(submission.subject).each do |strand|
          hash_key = level.id.to_s + strand.id.to_s
          @cell_correct[hash_key] = submission.correct_answers(:level=>level, :strand=>strand).size
          @cell_total[hash_key] = submission.total_answers(:level=>level, :strand=>strand).size
          @cell_pct[hash_key] = 0.0
        end
      end
    end
  end
  
  protected
  

  
end
