module ApplicationHelper
  def to_br(str)
    str.to_s.gsub!(/\r?\n/, '<br/>') unless str.blank?
#    str.to_s.gsub!(' ', '&nbsp') unless str.blank?
    return str
  end

  def core_image
    CoopApp.core.image_present? ? CoopApp.core.picture.url(:access) : nil
  end
end
