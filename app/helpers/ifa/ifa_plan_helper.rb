module Ifa::IfaPlanHelper

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
      label = (range.act_sat_map && sat) ? range.label_with_sat : range.range
    else
      label = 'Undefined Level'
    end
    label
  end
  def mastery_label_br(range, sat)
    if !range.nil?
      label = (range.act_sat_map && sat) ? range.label_with_sat_break : range.range
    else
      label = 'Undefined Level'
    end
    label
  end
  def benchmarks(strand, range, standard)
    benchmarks = []
    if !range.nil? && !strand.nil? && !standard.nil?
      benchmarks = standard.active_benches_strand_range(strand, range, ActBenchType.benchmark(standard))
    end
    benchmarks
  end

  def improvements(strand, range, standard)
    improvements = []
    if !range.nil? && !strand.nil? && !standard.nil?
      improvements = standard.active_benches_strand_range(strand, range, ActBenchType.improvement(standard))
    end
    improvements
  end

  def evidences(strand, range, standard)
    evidences = []
    if !range.nil? && !strand.nil? && !standard.nil?
      evidences = standard.active_benches_strand_range(strand, range, ActBenchType.evidence(standard))
    end
    evidences
  end

  def examples(strand, range, standard)
    examples = []
    if !range.nil? && !strand.nil? && !standard.nil?
      examples = standard.active_benches_strand_range(strand, range, ActBenchType.example(standard))
    end
    examples
  end

  def last_ifa_dashboard(entity, subject)
    entity.last_ifa_dashboard(subject)
  end

  def points_for_dashboard_cell(dashboard, range, strand)
    if !dashboard.nil? && !range.nil? && !strand.nil? && !dashboard.ifa_dashboard_cells.empty?
      dashboard.ifa_dashboard_cells.for_range_and_strand(range, strand).last.fin_points.to_i
    else
      0
    end
  end

  def answers_for_dashboard_cell(dashboard, range, strand)
    if !dashboard.nil? && !range.nil? && !strand.nil? && !dashboard.ifa_dashboard_cells.empty?
      dashboard.ifa_dashboard_cells.for_range_and_strand(range, strand).last.finalized_answers
    else
      0
    end
  end

  def correct_assessment_answers(submission, options={})
    if options[:level] && options[:strand]
    #  answers = submission.act_answers.correct.selected.select{|a| a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
      answers = submission.act_answers.correct.selected.select{|a| !a.act_question.nil? && a.act_question.act_score_range_id == options[:level].id && a.act_question.act_standard_id == options[:strand].id}
    elsif options[:level]
   #   answers = submission.act_answers.correct.selected.select{|a| a.act_question.of_mastery_level?(options[:level])}
      answers = submission.act_answers.correct.selected.select{|a| !a.act_question.nil? && a.act_question.act_score_range_id == options[:level].id}
    elsif options[:strand]
   #   answers = submission.act_answers.correct.selected.select{|a| a.act_question.of_strand?(options[:strand])}
      answers = submission.act_answers.correct.selected.select{|a| !a.act_question.nil?  && a.act_question.act_standard_id == options[:strand].id}
    else
      answers = submission.act_answers.correct.selected
    end
  end

  def incorrect_assessment_answers(submission, options={})
    if options[:level] && options[:strand]
      #  answers = submission.act_answers.incorrect.selected.select{|a| a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
      answers = submission.act_answers.incorrect.selected.select{|a| !a.act_question.nil? && a.act_question.act_score_range_id == options[:level].id && a.act_question.act_standard_id == options[:strand].id}
    elsif options[:level]
      #   answers = submission.act_answers.incorrect.selected.select{|a| a.act_question.of_mastery_level?(options[:level])}
      answers = submission.act_answers.incorrect.selected.select{|a| !a.act_question.nil? && a.act_question.act_score_range_id == options[:level].id}
    elsif options[:strand]
      #   answers = submission.act_answers.incorrect.selected.select{|a| a.act_question.of_strand?(options[:strand])}
      answers = submission.act_answers.incorrect.selected.select{|a| !a.act_question.nil?  && a.act_question.act_standard_id == options[:strand].id}
    else
      answers = submission.act_answers.incorrect.selected
    end
  end

  def total_assessment_answers(submission, options={})
    if options[:level] && options[:strand]
      #  answers = submission.act_answers.selected.select{|a| a.act_question.of_mastery_level?(options[:level]) && a.act_question.of_strand?(options[:strand])}
      answers = submission.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.act_score_range_id == options[:level].id && a.act_question.act_standard_id == options[:strand].id}
    elsif options[:level]
      #   answers = submission.act_answers.selected.select{|a| a.act_question.of_mastery_level?(options[:level])}
      answers = submission.act_answers.selected.select{|a| !a.act_question.nil? && a.act_question.act_score_range_id == options[:level].id}
    elsif options[:strand]
      #   answers = submission.act_answers.selected.select{|a| a.act_question.of_strand?(options[:strand])}
      answers = submission.act_answers.selected.select{|a| !a.act_question.nil?  && a.act_question.act_standard_id == options[:strand].id}
    else
      answers = submission.act_answers.selected
    end
  end

end
