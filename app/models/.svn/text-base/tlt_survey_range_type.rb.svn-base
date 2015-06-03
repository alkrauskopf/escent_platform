class TltSurveyRangeType < ActiveRecord::Base

  has_many :tlt_survey_questions



  def for_score(score)
    pretext = (score == 2 || score == 3) ? "Somewhat " : ""
    range = (score == 1 || score == 2) ? self.low_end : self.high_end
    string = pretext + range
  end

end
