class Ifa::IfaPlanController < Ifa::ApplicationController
#  helper :all # include all helpers, all the time

  layout "ifa_submission", :only=>[:evidence_edit, :evidence_update]

 # before_filter :set_ifa, :except=>[]
 # before_filter :current_app_enabled_for_current_org?, :except=>[]
  before_filter :current_user_app_authorized?, :only=>[:index]
  before_filter :current_user_app_admin?, :only=>[]
 # before_filter :current_ifa_options
  before_filter :current_app_superuser, :only=>[:index]
  before_filter :clear_notification, :except => [:take_assessment]
  before_filter :increment_app_views, :only=>[:index]

  def select_standard
    @current_standard = ActMaster.find_by_id(params[:act_master_id]) rescue nil
    standards = ActMaster.all
    render :partial => '/ifa/ifa_plan/select_standard', :locals=>{:standards=>standards}
  end

  def select_subject
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue ActSubject.na
    render :partial => '/ifa/ifa_plan/select_subject'
  end

  def plan_subject
    set_subject
    if @current_user.ifa_plan_subject(@subject).nil?
      @current_user.ifa_plans << IfaPlan.create(:act_subject_id=>@subject.id)
    end
    @user_plan = @current_user.ifa_plan_subject(@subject)
    @user_dashboard = @current_user.ifa_dashboards.last rescue nil
  end

  def plan_create
    set_subject
    if @current_user.ifa_plan_subject(@subject).nil?
      @current_user.ifa_plans << IfaPlan.create(:act_subject_id=>@subject.id)
    end
    @user_plan = @current_user.ifa_plan_subject(@subject)
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:subject => @subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_update
    set_plan
    set_classroom
    if @user_plan
      @user_plan.update_attributes(:needs=>params[:needs],:goals=>params[:goals])
    end
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:subject => @user_plan.act_subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_update_2
    set_plan
    if @user_plan
      @user_plan.update_attributes(:needs=>params[:ifa_plan][:needs],:goals=>params[:ifa_plan][:goals])
    end
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:subject => @user_plan.act_subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_show_form
    set_subject
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:subject => @subject, :show_form => true}
  end

  def plan_update_cancel
    set_subject
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:subject => @subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def milestone_create
    set_plan
    set_strand
    if @user_plan && @strand
      new_milestone = IfaPlanMilestone.new(:act_standard_id=>@strand.id)
      new_milestone.achieve_date = Time.now
      @user_plan.ifa_plan_milestones << new_milestone
    end
    @milestone = @user_plan.ifa_plan_milestones.last
    benchmarks_improvements
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => @milestone,
                                                                     :ranges => strand_ranges(@strand)}
  end

  def milestone_change
    set_milestone
    byebug
    benchmarks_improvements
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@milestone.plan, :strand => @milestone.strand,
                                                                     :new_milestone => @milestone,
                                                                     :ranges => strand_ranges(@milestone.strand)}
  end

  def milestone_update
    set_milestone
    @milestone.update_attributes(:description=>params[:description])
    @milestone.update_attributes(:evidence=>params[:evidence])
    milestone_destroy?(@milestone, false)
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_update_cancel
    set_milestone
    milestone_destroy?(@milestone, false)
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_destroy
    set_milestone
    milestone_destroy?(@milestone, true)
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_achieved
    set_milestone
    @milestone.update_attributes(:is_achieved=>true)
    milestone_destroy?(@milestone, false)
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @strand,
                                                                     :new_milestone => false, :ranges => @ranges}
  end

  def milestone_achieve_toggle
    set_milestone
    @milestone.update_attributes(:is_achieved=>!@milestone.is_achieved, :achieve_date => Time.now)
    render :partial =>  "/ifa/ifa_plan/teacher_show_milestone", :locals=>{:milestone => @milestone}
  end

  def milestone_range_select
    set_milestone
    set_range
    @milestone.update_attributes(:act_score_range_id=>@range.id)
    benchmarks_improvements
    render :partial =>  "/ifa/ifa_plan/form_milestone", :locals=>{:milestone => @milestone, :ranges => strand_ranges(@milestone.strand)}
  end

  def plan_teacher_review
    set_subject
    set_classroom
    set_student
    @plan = @student.ifa_plan_subject(@subject) rescue nil
    @remarks = @plan.nil? ? [] : @plan.remarks
    @new_remark = IfaPlanRemark.new
    @milestones= @plan.nil? ? nil:@plan.ifa_plan_milestones.by_last_updated
    render :partial =>  "/ifa/ifa_plan/teacher_show_plan", :locals=>{:milestones => @milestones, :remarks => @remarks,
                        :plan => @plan, :student=>@student}
  end

  def plan_teacher_remark_update
    set_plan
    set_classroom
    new_remark=IfaPlanRemark.new
    new_remark.remarks = params[:remarks]
    new_remark.user_id = @current_user.id
    new_remark.teacher_name = @current_user.last_name_first
    new_remark.course_name = @classroom.nil? ? '' : @classroom.name
    @user_plan.ifa_plan_remarks << new_remark
    render :partial =>  "/ifa/ifa_plan/teacher_remarks", :locals=>{:plan=> @user_plan, :remarks => @user_plan.remarks, :classroom => @classroom, :show_form=>false}
  end

  def plan_teacher_remark_destroy
    set_plan
    set_classroom
    set_remark
    @remark.destroy
    render :partial =>  "/ifa/ifa_plan/teacher_remarks", :locals=>{:plan=> @user_plan, :remarks => @user_plan.remarks, :classroom => @classroom, :show_form=>false}
  end

  def remark_show_form
    set_plan
    set_classroom
    @new_remark = IfaPlanRemark.new
    render :partial =>  "/ifa/ifa_plan/teacher_remarks", :locals=>{:plan=> @user_plan, :remarks => @user_plan.remarks, :classroom => @classroom, :show_form=>true}
  end

  def student_cell_data
    set_strand
    set_range
    set_student
  #  @correct_answers = @student.ifa_correct_answers(@strand.subject_area, :level=>@range, :strand=>@strand)
  #  @total_answers = @student.ifa_total_answers(@strand.subject_area, :level=>@range, :strand=>@strand)
    @assessments = @student.assessments_taken(:subject=>@strand.subject_area)
  end

  def evidence_form
    current_milestone
    current_evidence
    if @current_evidence.nil?
      @current_evidence = IfaPlanMilestoneEvidence.new
      evidence = 'New'
    else
      evidence = 'Edit'
    end
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => evidence}
  end

  def evidence_cancel
    current_milestone
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => 'No'}
  end

  def evidence_edit
    current_milestone
    current_evidence
    if @current_evidence.nil?
      @current_evidence = IfaPlanMilestoneEvidence.new
      @function = 'New'
    else
      @function = 'Edit'
    end
  end

  def evidence_update
    current_milestone
    if evidence_update_function == 'New'
      new_evidence
      if @current_milestone.evidences << @current_evidence
        flash[:notice] = 'Evidence Saved | Add Another'
        @current_evidence = IfaPlanMilestoneEvidence.new
      else
        flash[:error] = @current_evidence.errors.full_messages.to_sentence
      end
    else
      current_evidence
      update_evidence
    end
    @function = evidence_update_function
    render 'evidence_edit'
  end

  def evidence_show
    current_evidence
    current_milestone
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => 'No'}
  end

  def evidence_list
    current_milestone
    render :partial => "/ifa/ifa_plan/evidence_list", :locals => {:milestone => @current_milestone}
  end

  def evidence_updatex
    current_milestone
    #NEED TO Fgure out how to do Form in Partial
    current_evidence
    if @current_evidence.nil?
      @current_evidence = IfaPlanMilestoneEvidence.new
      evidence = 'New'
    else
      evidence = 'Edit'
    end
    render :partial => "form_milestone_evidence", :locals => {:milestone => @current_milestone, :function => evidence}
  end

  private

  def new_evidence
    @current_evidence = IfaPlanMilestoneEvidence.new
    @current_evidence.name = params[:ifa_plan_milestone_evidence][:name]
    @current_evidence.explanation = params[:ifa_plan_milestone_evidence][:explanation]
    @current_evidence.documentation = params[:ifa_plan_milestone_evidence][:documentation]
    @current_evidence.evidence = params[:ifa_plan_milestone_evidence][:evidence]
  end
  def update_evidence
    new_attach = params[:ifa_plan_milestone_evidence][:evidence] ? params[:ifa_plan_milestone_evidence][:evidence] : @current_evidence.evidence
    if (params[:attachment] && params[:attachment][:delete] == '1')
      new_attach = nil
    end
    if @current_evidence.update_attributes(:name => params[:ifa_plan_milestone_evidence][:name],
                                       :explanation => params[:ifa_plan_milestone_evidence][:explanation],
                                       :documentation => params[:ifa_plan_milestone_evidence][:documentation],
                                       :evidence => new_attach)
      flash[:notice] = 'Evidence Updated'
    else
      flash[:error] = @current_evidence.errors.full_messages.to_sentence
    end

  end

  def evidence_update_function
    params[:function]
  end

  def current_evidence
    @current_evidence = IfaPlanMilestoneEvidence.find_by_id(params[:ifa_plan_milestone_evidence_id]) rescue nil
  end

  def current_milestone
    @current_milestone = IfaPlanMilestone.find_by_id(params[:ifa_plan_milestone_id])
  end

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

  def set_remark
    @remark = IfaPlanRemark.find_by_public_id(params[:ifa_plan_remark_id])
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
