class Apps::IfaPlanController < ApplicationController
  helper :all # include all helpers, all the time

  before_filter :set_ifa, :except=>[]
  before_filter :clear_notification
#  after_filter :benchmarks_improvements, :only=>[:milestone_create, :milestone_update, :milestone_range_select]


  def current_standard
    @current_standard = ActMaster.find_by_id(params[:act_master_id]) rescue nil
  #  standards = @current_organization.ifa_org_option.act_masters rescue []
    standards = ActMaster.all
    render :partial => '/apps/ifa_plan/select_standard', :locals=>{:standards=>standards}
  end

  def current_subject
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue ActSubject.na
    render :partial => '/apps/ifa_plan/select_subject'
  end

  def plan_subject
    set_subject
    if @current_user.ifa_plan_subject(@subject).nil?
      @current_user.ifa_plans << IfaPlan.create(:act_subject_id=>@subject.id)
    end
    @user_plan = @current_user.ifa_plan_subject(@subject)
  end

  def plan_create
    set_subject
    if @current_user.ifa_plan_subject(@subject).nil?
      @current_user.ifa_plans << IfaPlan.create(:act_subject_id=>@subject.id)
    end
    @user_plan = @current_user.ifa_plan_subject(@subject)
    render :partial => "/apps/ifa_plan/manage_subj_plan", :locals=>{:subject => @subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_update
    set_plan
    if @user_plan
      @user_plan.update_attributes(:needs=>params[:needs],:goals=>params[:goals])
    end
    render :partial => "/apps/ifa_plan/manage_subj_plan", :locals=>{:subject => @user_plan.act_subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_update_2
    set_plan
    if @user_plan
      @user_plan.update_attributes(:needs=>params[:ifa_plan][:needs],:goals=>params[:ifa_plan][:goals])
    end
    render :partial => "/apps/ifa_plan/manage_subj_plan", :locals=>{:subject => @user_plan.act_subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_show_form
    set_subject
    render :partial => "/apps/ifa_plan/manage_subj_plan", :locals=>{:subject => @subject, :show_form => true}
  end

  def plan_update_cancel
    set_subject
    render :partial => "/apps/ifa_plan/manage_subj_plan", :locals=>{:subject => @subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def milestone_create
    set_plan
    set_strand
    if @user_plan && @strand
      @user_plan.ifa_plan_milestones << IfaPlanMilestone.create(:act_standard_id=>@strand.id)
    end
    @milestone = @user_plan.ifa_plan_milestones.last
    benchmarks_improvements
    render :partial => "/apps/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => @milestone,
                                                                     :ranges => strand_ranges(@strand)}
  end

  def milestone_change
    set_milestone
    benchmarks_improvements
    render :partial => "/apps/ifa_plan/strand_milestones", :locals=>{:plan=>@milestone.plan, :strand => @milestone.strand,
                                                                     :new_milestone => @milestone,
                                                                     :ranges => strand_ranges(@milestone.strand)}
  end

  def milestone_update
    set_milestone
    @milestone.update_attributes(:description=>params[:description])
    @milestone.update_attributes(:evidence=>params[:evidence])
    milestone_destroy?(@milestone, false)
    render :partial => "/apps/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_update_cancel
    set_milestone
    milestone_destroy?(@milestone, false)
    render :partial => "/apps/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_destroy
    set_milestone
    milestone_destroy?(@milestone, true)
    render :partial => "/apps/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_achieved
    set_milestone
    @milestone.update_attributes(:is_achieved=>true)
    milestone_destroy?(@milestone, false)
    render :partial => "/apps/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_achieve_toggle
    set_milestone
    @milestone.update_attributes(:is_achieved=>!@milestone.is_achieved)
    render :partial =>  "/apps/ifa_plan/teacher_show_milestone", :locals=>{:milestone => @milestone}
  end

  def milestone_range_select
    set_milestone
    set_range
    @milestone.update_attributes(:act_score_range_id=>@range.id)
    benchmarks_improvements
    render :partial =>  "/apps/ifa_plan/form_milestone", :locals=>{:milestone => @milestone, :ranges => strand_ranges(@milestone.strand)}
  end

  def plan_teacher_review
    set_subject
    set_classroom
    set_student
    @plan = @student.ifa_plan_subject(@subject)
    @remarks = @plan.remarks
    @new_remark = IfaPlanRemark.new
    @milestones= @plan.nil? ? nil:@plan.ifa_plan_milestones.by_last_updated
    render :partial =>  "/apps/ifa_plan/teacher_show_plan", :locals=>{:milestones => @milestones, :remarks => @remarks,
                        :plan => @plan, :student=>@student, :classroom=> @classroom}
  end

  def plan_teacher_remark_update
    set_plan
    set_classroom
    new_remark=IfaPlanRemark.new
    new_remark.remarks = params[:remarks]
    new_remark.user_id = @current_user.id
    new_remark.teacher_name = @current_user.last_name_first
    new_remark.course_name = @classroom.name
    @user_plan.ifa_plan_remarks << new_remark
    render :partial =>  "/apps/ifa_plan/teacher_remarks", :locals=>{:plan=> @user_plan, :remarks => @user_plan.ifa_plan_remarks, :classroom => @classroom}
  end

  private

  def set_subject
    @subject = ActSubject.find(params[:subject_id]) rescue nil
    if @subject.nil?
      @subject = ActSubject.find_by_public_id(params[:act_subject_id]) rescue nil
    end
  end

  def set_plan
    @user_plan = IfaPlan.find_by_public_id(params[:ifa_plan_id])
  end

  def set_milestone
    @milestone = IfaPlanMilestone.find_by_public_id(params[:ifa_plan_milestone_id])
  end

  def set_strand
    @strand = ActStandard.find_by_public_id(params[:act_standard_id])
  end

  def set_range
    @range = ActScoreRange.find_by_public_id(params[:act_score_range_id])
  end

  def set_student
    @student = User.find_by_public_id(params[:student_id]) rescue nil
  end

  def set_classroom
    if params[:classroom_id]
      @classroom = Classroom.find_by_public_id(params[:classroom_id]) rescue nil
    else
      @classroom = nil
    end
  end

  def strand_ranges(strand)
    standard = strand.act_master
    subject = strand.act_subject
    standard.act_score_ranges.no_na.for_subject(subject)
  end

  def benchmarks_improvements
    if @milestone && @milestone.range? && @milestone.strand? && @milestone.standard?
      @benchmarks = @milestone.standard.benchmarks_for_strand_range(@milestone.strand, @milestone.range)
      @improvements = @milestone.standard.improvements_for_strand_range(@milestone.strand, @milestone.range)
      @evidences = @milestone.standard.evidence_for_strand_range(@milestone.strand, @milestone.range)
    else
      @benchmarks = []
      @improvements = []
      @evidences = []
    end
  end

  def milestone_destroy?(milestone,force)
    @user_plan = @milestone.plan
    @strand = @milestone.strand
    @ranges = strand_ranges(@milestone.strand)
    if milestone.description.nil? || milestone.description.empty? || force
      milestone.destroy
    end
  end

end
