class IfaPlanMetric < ActiveRecord::Base
  attr_accessible :act_subject_id, :entity_id, :entity_type, :is_uptodate
  include PublicPersona

  belongs_to :entity, :polymorphic => true
  belongs_to :act_subject

  has_many  :metrics, :class_name => 'IfaPlanMetricCell', :dependent => :destroy

  def self.for_subject(subject)
    where('act_subject_id = ?', subject.id)
  end

  def self.metric_table(subject)
    where('act_subject_id = ?', subject.id).last rescue nil
  end

  def self.up_to_date
    where('is_uptodate')
  end

  def self.update_needed
    where('is_uptodate = ?', false)
  end

  def up_to_date?
    self.is_uptodate
  end

  def subject
    self.act_subject
  end

  def self.reinitialize(entity, subject, standard)
    if !entity.ifa_plan_metrics.metric_table(subject).nil?
      entity.ifa_plan_metrics.metric_table(subject).destroy
    end
    self.new_metrics_table(entity, subject, standard)
    metric_table = entity.ifa_plan_metrics.metric_table(subject)
    students = []
    if entity.class.to_s == 'User'
      students << entity
    elsif entity.class.to_s == 'Classroom'
      students << entity.students.compact
    elsif entity.class.to_s == 'Organization'
      students << entity.classrooms.ifa_students_subject(subject).compact
    end
    metric_table.load_all_cells(students.flatten, subject, standard)
  end

  def self.plan(student, subject, standard, function)
    if function == 'New'
      increment = 1
      if student.ifa_plan_metrics.metric_table(subject).nil?
        self.new_metrics_table(student, subject, standard)
      end
      student.ifa_plan_metrics.metric_table(subject).update_cell('total', :plan => increment)
      classrooms = student.active_ifa_offerings(subject)
      classrooms.each do |classroom|
        if classroom.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(classroom, subject, standard)
        end
        classroom.ifa_plan_metrics.metric_table(subject).update_cell('total', :plan => increment)
      end
      orgs = classrooms.map{|c| c.organization.nil? ? nil : c.organization}.compact rescue []
      orgs.each do |org|
        if org.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(org, subject, standard)
        end
        org.ifa_plan_metrics.metric_table(subject).update_cell('total', :plan => increment)
      end
    end
  end

  def self.new_metrics_table(entity, subject, standard)
    entity.ifa_plan_metrics << IfaPlanMetric.new(:act_subject_id => subject.id)
    metric_table = entity.ifa_plan_metrics.metric_table(subject)
    metric_table.create_metric_cells(subject, standard)
  end

  def self.milestone(milestone, function)
    increment = function == 'New' ? 1 : -1
    if milestone.ifa_plan && milestone.ifa_plan.user && milestone.ifa_plan.subject_area && milestone.standard && milestone.range
      student = milestone.ifa_plan.user
      subject = milestone.ifa_plan.subject_area
      if student.ifa_plan_metrics.metric_table(subject).nil?
        self.new_metrics_table(student, subject, milestone.standard)
      end
      metric_table = student.ifa_plan_metrics.metric_table(subject)
      metric_table.update_cells(milestone.range, milestone.strand, :in_process => increment)
      classrooms = student.active_ifa_offerings(subject)
      classrooms.each do |classroom|
        if classroom.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(classroom, subject, milestone.standard)
        end
        metric_table = classroom.ifa_plan_metrics.metric_table(subject)
        metric_table.update_cells(milestone.range, milestone.strand, :in_process => increment)
      end
      orgs = classrooms.map{|c| c.organization.nil? ? nil : c.organization}.compact rescue []
      orgs.each do |org|
        if org.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(org, subject, milestone.standard)
        end
        metric_table = org.ifa_plan_metrics.metric_table(subject)
        metric_table.update_cells(milestone.range, milestone.strand, :in_process => increment)
      end
    end
  end

  def self.milestone_achieved(milestone, function)
    increment = function == 'Do' ? 1 : -1
    if milestone.ifa_plan && milestone.ifa_plan.user && milestone.ifa_plan.subject_area && milestone.standard && milestone.range
      student = milestone.ifa_plan.user
      subject = milestone.ifa_plan.subject_area
      if student.ifa_plan_metrics.metric_table(subject).nil?
        self.new_metrics_table(student, subject, milestone.standard)
      end
      metric_table = student.ifa_plan_metrics.metric_table(subject)
      metric_table.update_cells(milestone.range, milestone.strand, :in_process => -increment, :achieved => increment)
      classrooms = student.active_ifa_offerings(subject)
      classrooms.each do |classroom|
        if classroom.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(classroom, subject, milestone.standard)
        end
        metric_table = classroom.ifa_plan_metrics.metric_table(subject)
        metric_table.update_cells(milestone.range, milestone.strand, :in_process => -increment, :achieved => increment)
      end
      orgs = classrooms.map{|c| c.organization.nil? ? nil : c.organization}.compact rescue []
      orgs.each do |org|
        if org.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(org, subject, milestone.standard)
        end
        metric_table = org.ifa_plan_metrics.metric_table(subject)
        metric_table.update_cells(milestone.range, milestone.strand, :in_process => -increment, :achieved => increment)
      end
    end
  end

  def self.evidence_metric(milestone, function)
    increment = function == 'New' ? 1 : -1
    if milestone.ifa_plan && milestone.ifa_plan.user && milestone.ifa_plan.subject_area && milestone.standard && milestone.range
      student = milestone.ifa_plan.user
      subject = milestone.ifa_plan.subject_area
      if student.ifa_plan_metrics.metric_table(subject).nil?
        self.new_metrics_table(student, subject, milestone.standard)
      end
      metric_table = student.ifa_plan_metrics.metric_table(subject)
      metric_table.update_cells(milestone.range, milestone.strand, :evidence => increment)
      classrooms = student.active_ifa_offerings(subject)
      classrooms.each do |classroom|
        if classroom.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(classroom, subject, milestone.standard)
        end
        metric_table = classroom.ifa_plan_metrics.metric_table(subject)
        metric_table.update_cells(milestone.range, milestone.strand, :evidence => increment)
      end
      orgs = classrooms.map{|c| c.organization.nil? ? nil : c.organization}.compact rescue []
      orgs.each do |org|
        if org.ifa_plan_metrics.metric_table(subject).nil?
          self.new_metrics_table(org, subject, milestone.standard)
        end
        metric_table = org.ifa_plan_metrics.metric_table(subject)
        metric_table.update_cells(milestone.range, milestone.strand, :evidence => increment)
      end
    end
  end

  def self.remark(student, subject, standard, function)
    increment = function == 'New' ? 1 : -1
    if student.ifa_plan_metrics.metric_table(subject).nil?
      self.new_metrics_table(student, subject, standard)
    end
    student.ifa_plan_metrics.metric_table(subject).update_cell('total', :remarks => increment)
    classrooms = student.active_ifa_offerings(subject)
    classrooms.each do |classroom|
      if classroom.ifa_plan_metrics.metric_table(subject).nil?
        self.new_metrics_table(classroom, subject, standard)
      end
      classroom.ifa_plan_metrics.metric_table(subject).update_cell('total', :remarks => increment)
    end
    orgs = classrooms.map{|c| c.organization.nil? ? nil : c.organization}.compact rescue []
    orgs.each do |org|
      if org.ifa_plan_metrics.metric_table(subject).nil?
        self.new_metrics_table(org, subject, standard)
      end
      org.ifa_plan_metrics.metric_table(subject).update_cell('total', :remarks => increment)
    end
  end

  def load_all_cells(students, subject, standard)
    self.update_cell('total', :plan =>(students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : 1}.sum),
                     :remarks => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).remarks.size}.sum),
                     :in_process => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.not_achieved.size}.flatten.compact.sum),
                     :achieved => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.achieved.size}.flatten.compact.sum),
                     :evidence => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.map{|m| m.evidence_count}}.flatten.compact.sum)
    )

    standard.act_standards.active.for_subject(subject).each do |strand|
      self.update_cell(('strand'+ strand.id.to_s), :in_process => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.open_for_strand(strand).size}.flatten.compact.sum),
                       :achieved => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.for_strand(strand).achieved.size}.flatten.compact.sum),
                       :evidence => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.for_strand(strand).map{|m| m.evidence_count}.flatten}.flatten.compact.sum)
                       )
    end
    standard.act_score_ranges.active.for_subject(subject).each do |level|
      self.update_cell(('level'+ level.id.to_s), :in_process => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.open_for_range(level).size}.flatten.compact.sum),
                       :achieved => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.for_range(level).achieved.size}.flatten.compact.sum),
                       :evidence => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.for_range(level).map{|m| m.evidence_count}.flatten}.flatten.compact.sum)
      )
      standard.act_standards.active.for_subject(subject).each do |strand|
        self.update_cell((level.id.to_s + '|' + strand.id.to_s), :in_process => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.open_for_range_strand(level, strand).size}.flatten.compact.sum),
                         :achieved => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.for_range_strand(level, strand).achieved.size}.flatten.compact.sum),
                         :evidence => (students.map{|s| s.ifa_plan_for(subject).nil? ? 0 : s.ifa_plan_for(subject).ifa_plan_milestones.for_range_strand(level, strand).map{|m| m.evidence_count}.flatten}.flatten.compact.sum)
        )
      end
    end
  end

  def update_cells(level, strand, options={})
    self.update_cell('total', options)
    self.update_cell('strand'+ strand.id.to_s, options)
    self.update_cell('level'+ level.id.to_s, options)
    self.update_cell((level.id.to_s + '|' + strand.id.to_s), options)
  end

  def update_cell(cell_name, options = {})
    metric_cell = self.metrics.in_cell(cell_name) rescue nil
    if metric_cell.nil?
      self.new_cell(cell_name)
      metric_cell = self.metrics.in_cell(cell_name) rescue nil
    end
    if !metric_cell.nil?
      metric_cell.update_attributes(:plans => metric_cell.plans + (options[:plan] ? options[:plan] : 0),
                                    :in_process => metric_cell.in_process + (options[:in_process] ? options[:in_process] : 0),
                                    :achieved => metric_cell.achieved + (options[:achieved] ? options[:achieved] : 0),
                                    :remarks => metric_cell.remarks + (options[:remarks] ? options[:remarks] : 0),
                                    :evidences => metric_cell.evidences + (options[:evidence] ? options[:evidence] : 0)
      )
    end
  end

  def create_metric_cells(subject, standard)
    self.new_cell('total')
    standard.act_standards.active.for_subject(subject).each do |strand|
      self.new_cell(('strand'+ strand.id.to_s))
    end
    standard.act_score_ranges.active.for_subject(subject).each do |level|
      self.new_cell(('level'+ level.id.to_s))
      standard.act_standards.active.for_subject(subject).each do |strand|
        self.new_cell((level.id.to_s + '|' + strand.id.to_s))
      end
    end
  end

  def new_cell(cell_name)
    metric_cell = IfaPlanMetricCell.new(:ifa_plan_metric_id=>self.id, :cell=>cell_name)
    metric_cell.save
  end

end
