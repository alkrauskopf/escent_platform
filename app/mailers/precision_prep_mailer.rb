class PrecisionPrepMailer < ActionMailer::Base
  default from: "no-reply@PrecisionSchoolImprovement.com"
  layout "precision_prep_mailer_old", :except=>['prep_guardian_add', 'milestone_created_guardian',
                                                'milestone_created_student', 'milestone_created_teacher',
                                                'milestone_created_teacher_group', 'remark_student', 'remark_guardian',
                                                'prep_guardian_inquiry', 'prep_student_inquiry']

  def assessment_submission(recipient, sender, classroom, organization, must_review, ep_host)
    @organization = organization
    @classroom = classroom
    @sender = sender
    @recipient = recipient
    @subject_line = @sender.full_name + ' Submitted An Assessment'
    @ep_host = ep_host
    @review_msg = must_review ? 'Your Review Of The Assessment Is Required.' : 'Assessment Results Have Been Automatically Finalized.'
    @from = 'SAT/ACT Prep Assessment<noreply@PrecisionSchoolImprovement.com>'
    unless @recipients.blank? || @sender.blank?
      mail(to: @recipient, subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def plan_created_student(user, plan, ep_host)
    student_info(user)
    org_info(user.organization)
    guardian_cc(user)
    plan_info(plan)
    @recipient_list = user.preferred_email
    @subject_line = 'SAT/ACT Prep Plan Created'
    @ep_host = ep_host
    @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
    if !@recipient_list.nil? && !@recipient_list.empty?
      mail(to:@recipient_list , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def plan_created_guardian(user, plan, ep_host)
    if !user.guardians.empty?
      student_info(user)
      org_info(user.organization)
      guardian_cc(user)
      plan_info(plan)
      @subject_line = 'SAT/ACT Prep Plan Created'
      @ep_host = ep_host
      @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
      user.guardians.each do |guardian|
        guardian_info(guardian)
        mail(to:guardian.email_address , subject: @subject_line, from: @from, date: DateTime.now)
        guardian.increment_notify
      end
    end
  end

  def milestone_created_student(user, milestone, ep_host)
    student_info(user)
    org_info(user.organization)
    milestone_info(milestone)
    guardian_cc(user)
    @recipient_list = user.preferred_email
    @subject_line = @school_name + ' SAT/ACT Prep Milestone Notification'
    @ep_host = ep_host
    @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
    if !@recipient_list.nil? && !@recipient_list.empty?
      mail(to:@recipient_list , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def milestone_created_guardian(user, milestone, ep_host)
    if !user.guardians.empty?
      student_info(user)
      org_info(user.organization)
      milestone_info(milestone)
      @subject_line = @school_name + ' SAT/ACT Milestone: Guardian Notification'
      @ep_host = ep_host
      @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
      user.guardians.each do |guardian|
        guardian_info(guardian)
        mail(to:guardian.email_address , subject: @subject_line, from: @from, date: DateTime.now)
        guardian.increment_notify
      end
    end
  end

  def milestone_created_teacher(user, teacher, milestone, ep_host)
    if !teacher.nil?
      student_info(user)
      org_info(user.organization)
      milestone_info(milestone)
      guardian_cc(user)
      plan_info(@plan)
      @subject_line = user.last_name + ' Milestone Notification'
      @ep_host = ep_host
      @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
      mail(to:teacher.preferred_email , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def milestone_new_teacher(user, teacher, milestone, ep_host)
    if !teacher.nil?
      student_info(user)
      org_info(user.organization)
      milestone_info(milestone)
      guardian_cc(user)
      plan_info(@plan)
      @subject_line = user.last_name + ' Milestone Notification'
      @ep_host = ep_host
      @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
      mail(to:teacher.preferred_email , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def milestone_created_teacher_group(user, teachers, milestone, ep_host)
    if !teachers.empty?
      student_info(user)
      org_info(user.organization)
      milestone_info(milestone)
      guardian_cc(user)
      plan_info(@plan)
      @recipients = User.preferred_email_list(teachers)
      @subject_line = user.last_name + ' Milestone Notification'
      @ep_host = ep_host
      @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
      unless @recipients.blank?
        mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
      end
    end
  end

  def prep_student_inquiry(user, org, ep_host)
    student_info(user)
    org_info(org)
    guardian_cc(user)
    @recipient_list = org.ifa_admin_email_list
    @subject_line = user.last_name + ' Precision Prep Inquiry'
    @ep_host = ep_host
    @from = 'SAT/ACT Prep Inquiry<noreply@PrecisionSchoolImprovement.com>'
    unless @recipient_list == ''
      mail(to:@recipient_list , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def prep_guardian_inquiry(user, guardian, org, ep_host)
    student_info(user)
    org_info(org)
    guardian_cc(user)
    guardian_info(guardian)
    @recipient_list = org.ifa_admin_email_list
    @subject_line = guardian.full_name + ' Precision Prep Inquiry'
    @ep_host = ep_host
    @from = 'SAT/ACT Prep Inquiry<noreply@PrecisionSchoolImprovement.com>'
    unless @recipient_list == ''
      mail(to:@recipient_list , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def prep_guardian_add(user, guardian, ep_host)
    student_info(user)
    guardian_cc(user)
    guardian_info(guardian)
    org_info(user.organization)
    @recipient_list = @guardian_email + ', ' + @student_email
    @subject_line = @student.last_name + ' Student Guardian Identified'
    @ep_host = ep_host
    @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
    unless @recipient_list == ''
      mail(to:@recipient_list , subject: @subject_line, from: @from, date: DateTime.now)
      guardian.increment_notify
    end
  end

  def remark_student(student, plan, remark, teacher, ep_host)
    student_info(student)
    org_info(student.organization)
    plan_info(plan)
    teacher_info(teacher)
    guardian_cc(student)
    @remark = remark
    @recipient_list = student.preferred_email
    @subject_line = @school_name + ' SAT/ACT Prep Teacher Remark'
    @ep_host = ep_host
    @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
    if !@recipient_list.nil? && !@recipient_list.empty?
      mail(to:@recipient_list , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def remark_guardian(student, plan, remark, teacher, ep_host)
    if !student.guardians.empty?
      student_info(student)
      org_info(student.organization)
      plan_info(plan)
      teacher_info(teacher)
      @recipient_list = student.preferred_email
      @remark = remark
      @subject_line = @school_name + ' SAT/ACT Prep Teacher Remark'
      @ep_host = ep_host
      @from = 'SAT/ACT Prep Plan<noreply@PrecisionSchoolImprovement.com>'
      student.guardians.each do |guardian|
        guardian_info(guardian)
        mail(to:guardian.email_address , subject: @subject_line, from: @from, date: DateTime.now)
        guardian.increment_notify
      end
    end
  end

  private

  def student_info(student)
    @student_first_name = student.first_name.titleize
    @student_full_name = student.full_name.titleize
    @student = student
    @student_email = @student.preferred_email
    @student_phone = (@student.phone.nil? || @student.phone == '') ? 'Not Known' : @student.phone
  end

  def guardian_info(guardian)
    @guardian_full_name = guardian.full_name.titleize
    @guardian_email = guardian.email_address
    @guardian_phone = (guardian.phone.nil? || guardian.phone == '') ? 'Not Known' :guardian.phone
    @guardian_id = guardian.public_id
    @guardian_first_name = guardian.first_name == '' ? 'Guardian' : guardian.first_name.titleize
  end

  def teacher_info(teacher)
    @teacher_full_name = teacher.full_name.titleize
    @teacher_last_name = teacher.last_name.titleize
    @teacher = teacher
    @teacher_email = @teacher.preferred_email
  end

  def org_info(org)
    @school_name = org.short_name
    @school_full_name = org.name
    @organization = org
  end

  def plan_info(plan)
    @subject_area = plan.subject_area.name
    @plan = plan
    @plan_needs = plan.needs.blank? ? 'Not Defined'  : plan.needs
    @plan_goals = plan.goals.blank? ? 'Not Defined'  : plan.goals
    @miles_defined = plan.milestones.size
    @miles_achieved = plan.milestones.achieved.size
  end

  def milestone_info(milestone)
    @milestone = milestone
    @plan = milestone.ifa_plan
    @subject_area = @plan.subject_area.name
    @act_subject = @plan.subject_area
    @strand_name = milestone.strand.name.titleize
    @mastery_level = milestone.range.range
    @teacher_name = milestone.teacher.nil? ? nil : milestone.teacher.full_name.titleize
  end

  def guardian_cc(user)
    @guardian_cc = user.guardians.empty? ? 'No Guardians' : (user.guardian_name_list)
    @guardian_count = user.guardians.size
    @cc_list = user.guardian_name_list
  end
end
