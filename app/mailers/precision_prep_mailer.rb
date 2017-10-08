class PrecisionPrepMailer < ActionMailer::Base
  default from: "no-reply@PrecisionSchoolImprovement.com"

  def assessment_submission(recipient, sender, classroom, organization, must_review, ep_host)
    @organization = organization
    @classroom = classroom
    @sender = sender
    @recipient = recipient
    @subject_line = @sender.full_name + ' Submitted An Assessment'
    @ep_host = ep_host
    @review_msg = must_review ? 'Your Review Of The Assessment Is Required.' : 'Assessment Results Have Been Automatically Finalized.'
    @from = 'precision_assessment<noreply@PrecisionSchoolImprovement.com>'
    unless @recipients.blank? || @sender.blank?
      mail(to: @recipient, subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def plan_created_student(user, plan, ep_host)
      @user_name = user.first_name
      @full_name = user.full_name
      @school_name = user.organization.short_name
      @subject_area = plan.subject_area.name
      @needs = plan.needs.blank? ? 'Not Defined'  : plan.needs
      @goals = plan.goals.blank? ? 'Not Defined'  : plan.goals
      @miles_defined = plan.milestones.size
      @miles_achieved = plan.milestones.achieved.size
      @recipients = user.guardians.empty? ? user.preferred_email : (user.preferred_email + ', ' + user.guardian_email_list)
      @subject_line = 'Growth Plan Created'
      @ep_host = ep_host
      @from = 'precision_plan<noreply@PrecisionSchoolImprovement.com>'
      unless @recipients.blank?
        mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
      end
  end

  def plan_updated_student(user, plan, ep_host)
    @user_name = user.first_name
    @full_name = user.full_name
    @school_name = user.organization.short_name
    @subject_area = plan.subject_area.name
    @needs = plan.needs.blank? ? 'Not Defined'  : plan.needs
    @goals = plan.goals.blank? ? 'Not Defined'  : plan.goals
    @miles_defined = plan.milestones.size
    @miles_achieved = plan.milestones.achieved.size
    @recipients = user.guardians.empty? ? user.preferred_email : (user.preferred_email + ', ' + user.guardian_email_list)
    @subject_line = 'Growth Plan Updated'
    @ep_host = ep_host
    @from = 'precision_plan<noreply@PrecisionSchoolImprovement.com>'
    unless @recipients.blank?
      mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def milestone_created_student(user, milestone, ep_host)
    @user_name = user.first_name
    @full_name = user.full_name
    @school_name = user.organization.short_name
    @milestone = milestone
    @plan = milestone.ifa_plan
    @subject_area = @plan.subject_area.name
    @strand_name = @milestone.strand.name.titleize
    @mastery_level = @milestone.range.range
    @recipients = user.guardians.empty? ? user.preferred_email : (user.preferred_email + ', ' + user.guardian_email_list)
    @subject_line = 'Milestone Created'
    @ep_host = ep_host
    @from = 'precision_plan<noreply@PrecisionSchoolImprovement.com>'
    unless @recipients.blank?
      mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def milestone_updated_student(user, milestone, ep_host)
    @user_name = user.first_name
    @full_name = user.full_name
    @school_name = user.organization.short_name
    @milestone = milestone
    @plan = milestone.ifa_plan
    @subject_area = @plan.subject_area.name
    @strand_name = @milestone.strand.name.titleize
    @mastery_level = @milestone.range.range
    @recipients = user.guardians.empty? ? user.preferred_email : (user.preferred_email + ', ' + user.guardian_email_list)
    @subject_line = 'Milestone Updated'
    @ep_host = ep_host
    @from = 'precision_plan<noreply@PrecisionSchoolImprovement.com>'
    unless @recipients.blank?
      mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

  def milestone_created_guardian(user, milestone, ep_host)
    if !user.guardians.empty?
      @user_name = user.first_name
      @school_name = user.organization.short_name
      @milestone = milestone
      @plan = milestone.ifa_plan
      @subject_area = milestone.ifa_plan.subject_area.name
      @strand_name = @milestone.strand.name.titleize
      @mastery_level = @milestone.range.range
      @recipients = user.guardian_email_list
      @subject_line = 'Learning Milestone Notification'
      @ep_host = ep_host
      @from = 'precision_plan<noreply@PrecisionSchoolImprovement.com>'
      unless @recipients.blank?
        mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
      end
    end
  end

  def milestone_created_teacher(user, teachers, milestone, ep_host)
    @user_name = user.full_name
    @school_name = user.organization.short_name
    @milestone = milestone
    @plan = milestone.ifa_plan
    @subject_area = milestone.ifa_plan.subject_area.name
    @strand_name = @milestone.strand.name.titleize
    @mastery_level = @milestone.range.range
    @recipients = User.preferred_email_list(teachers)
    @subject_line = user.last_name + ' Learning Milestone Notification'
    @ep_host = ep_host
    @from = 'precision_plan<noreply@PrecisionSchoolImprovement.com>'
    unless @recipients.blank?
      mail(to:@recipients , subject: @subject_line, from: @from, date: DateTime.now)
    end
  end

end
