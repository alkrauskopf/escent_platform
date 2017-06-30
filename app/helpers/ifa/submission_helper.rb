module Ifa::SubmissionHelper

  def dashboard_label(dashboard, standard)
    if !dashboard.nil? && !standard.nil?
      period = dashboard.period_end.strftime("%b %Y")
      score = dashboard.score_for_standard(standard).nil? ? 'No Score' : dashboard.score_for_standard(standard).standard_score
      label = period + ' - ' + standard.abbrev + ' ' + score.to_s
    else
      label = 'Undefined Dashboard'
    end
    label
  end
  def dashboard_score(dashboard, standard)
    if !dashboard.nil? && !standard.nil?
      score = dashboard.score_for_standard(standard).nil? ? 'No Score' : dashboard.score_for_standard(standard).standard_score
      label = standard.abbrev + ' ' + score.to_s
    else
      label = 'No Score'
    end
    label
  end
end
