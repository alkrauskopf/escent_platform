module Apps::IfaPlanHelper

  def achievement_level(strand, level)
    if !strand.nil? && !level.nil?
      standard = strand.act_master
      subject = strand.act_subject
      ranges = standard.act_score_ranges.no_na.for_subject(subject)
      achieve = ranges.index(level) + 1
    else
      achieve = 0
    end
    achieve
  end
end
