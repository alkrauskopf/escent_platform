module Apps::LearningTimeHelper

  def letter_equivalent(number)
    letters = ('a'..'z').to_a
    number.nil? ? '' : letters[(number-1)%26]
  end

  def indicator_tiered_label(indicator)
    if  indicator.standard?
      indicator.standard.abbrev + '.' + indicator.element.position.to_s + '.' + letter_equivalent(indicator.position)
    else
      indicator.position
    end
  end
end
