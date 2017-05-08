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
  def mastery_label(range, sat)
    if !range.nil?
      label = sat ? range.label_with_sat : range.range
    else
      label = 'Undefined Level'
    end
    label
  end
  def benchmarks(strand, range, standard)
    benchmarks = []
    if !range.nil? && !strand.nil? && !standard.nil?
      benchmarks = standard.benchmarks_for_strand_range(strand, range)
    end
    benchmarks
  end
  def improvements(strand, range, standard)
    improvements = []
    if !range.nil? && !strand.nil? && !standard.nil?
      improvements = standard.improvements_for_strand_range(strand, range)
    end
    improvements
  end
end
