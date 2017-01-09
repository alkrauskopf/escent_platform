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

end
