module ApplicationHelper
  def to_br(str)
    str.to_s.gsub!(/\r?\n/, '<br/>') unless str.blank?
#    str.to_s.gsub!(' ', '&nbsp') unless str.blank?
    return str
  end

  def captcha_pick
    if CaptchaImage.all.empty?
      current_captcha = nil
    else
      max = CaptchaImage.all.size - 1
      current_captcha = CaptchaImage.all[rand(0..max)]
    end
    current_captcha
  end

  def scores_with_sat_equivalent(sms, standard, subject)
    if !sms.nil? && !standard.nil? && !subject.nil?
      label = standard.abbrev + ': ' + sms.to_s
      sat_score = ActScoreRange.sat_score(standard, subject, sms)
      label = sat_score.nil? ?  label: (label + ', SAT:' + sat_score.to_s)
    else
      label = "Nil Parameter"
    end
      label
  end

end
