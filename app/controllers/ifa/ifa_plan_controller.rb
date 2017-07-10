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
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_user, :subject => @subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_update
    set_plan
    set_classroom
    if @user_plan
      @user_plan.update_attributes(:needs=>params[:needs],:goals=>params[:goals])
    end
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_user, :subject => @user_plan.act_subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_update_2
    set_plan
    if @user_plan
      @user_plan.update_attributes(:needs=>params[:ifa_plan][:needs],:goals=>params[:ifa_plan][:goals])
    end
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_user, :subject => @user_plan.act_subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def plan_show_form
    set_subject
    @user_plan = @current_user.ifa_plan_subject(@subject)
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_user, :subject => @subject, :show_form => true}
  end

  def plan_update_cancel
    set_subject
    @user_plan = @current_user.ifa_plan_subject(@subject)
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_user, :subject => @subject, :show_form => @current_user.show_ifa_plan_form?(@subject)}
  end

  def milestone_create
    set_plan
    current_strand
    @current_milestone = IfaPlanMilestone.new(:act_standard_id=>@current_strand.id)
    benchmarks_improvements
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                     :milestone_form => 'New',
                                                                     :ranges => strand_ranges(@current_strand)}
  end

  def milestone_change
    set_milestone
    @current_range = @current_milestone.range
    @current_strand = @current_milestone.strand
    benchmarks_improvements
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@current_milestone.plan, :strand => @current_strand,
                                                                    :milestone_form => 'Change',
                                                                     :ranges => strand_ranges(@milestone.strand)}
  end

  def milestone_update
    current_strand
    current_range
    set_plan
    if new_milestone?
      @current_milestone = IfaPlanMilestone.new
      @current_milestone.act_score_range_id = @current_range.id
      @current_milestone.act_standard_id = @current_strand.id
      @current_milestone.description = params[:description]
      @current_milestone.achieve_date = Time.now
      @user_plan.milestones << @current_milestone
    else
      current_milestone
      @current_milestone.update_attributes(:description=>params[:description], :act_score_range_id => @current_range.id)
    end
    set_plan
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                    :milestone_form => 'No', :ranges => @user_plan.ranges(@current_standard)}
  end

  def milestone_update_cancel
    set_plan
    current_strand
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                    :milestone_form => 'No', :ranges => @user_plan.ranges(@current_standard)}
  end

  def milestone_destroy
    current_milestone
    current_strand
    set_plan
    @current_milestone.destroy
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                    :milestone_form => 'No', :ranges => @user_plan.ranges(@current_standard)}
  end

  def milestone_achieved
    current_milestone
    @current_milestone.update_attributes(:is_achieved=>!@current_milestone.is_achieved, :achieve_date => Time.now)
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => 'No'}
  end

  def milestone_achieve_toggle
    set_milestone
    @milestone.update_attributes(:is_achieved=>!@milestone.is_achieved, :achieve_date => Time.now)
    render :partial =>  "/ifa/ifa_plan/teacher_show_milestone", :locals=>{:milestone => @milestone}
  end

  def milestone_range_select
    set_plan
    current_milestone
    @current_milestone ||= IfaPlanMilestone.new
    current_strand
    current_range
    benchmarks_improvements
    render :partial =>  "/ifa/ifa_plan/form_milestone", :locals=>{:milestone => @current_milestone, :function => milestone_function, :plan => @user_plan, :strand => @current_strand, :ranges => @user_plan.ranges(@current_standard)}
  end

  def plan_teacher_review
    current_subject
    current_student
    @user_plan = @current_student.ifa_plan_subject(@current_subject) rescue nil
    @remarks = @user_plan.nil? ? [] : @user_plan.remarks
    @milestones= @user_plan.nil? ? nil : @user_plan.ifa_plan_milestones.by_last_updated
    render :partial => "/ifa/ifa_plan/teacher_review_plan", :locals=>{:student_plan => @user_plan, :student => @current_student, :subject => @current_subject, :show => "Yes"}
  end

  def plan_teacher_review_close
    current_subject
    current_student
    render :partial => '/ifa/ifa_plan/teacher_review_plan', :locals=>{:student => @current_student, :subject => @current_subject, :show => 'No'}
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
    current_strand
    current_range
    set_student
    @assessments = @current_student.assessments_taken(:subject=>@current_strand.subject_area)
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
        flash[:notice] = 'Evidence Saved | Add More Evidence, Or Close Browser Window'
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

  def show_html
    current_evidence
    render :layout => "assessment"
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

  def current_range
    @current_range = ActScoreRange.find_by_id(params[:act_score_range_id])
  end

  def current_strand
    @current_strand = ActStandard.find_by_id(params[:act_standard_id])
  end

  def new_milestone?
    params[:function] && params[:function] == 'New'
  end

  def milestone_function
    params[:function]
  end

  def set_subject
    @current_subject = ActSubject.find(params[:subject_id]) rescue nil
    if @current_subject.nil?
      @current_subject = ActSubject.find_by_public_id(params[:act_subject_id]) rescue nil
    end
  end
  def current_subject
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
  end

  def set_plan
    @user_plan = IfaPlan.find_by_public_id(params[:ifa_plan_id]) rescue nil
    if @user_plan.nil?
      @user_plan = IfaPlan.find_by_id(params[:ifa_plan_id]) rescue nil
    end
  end

  def set_milestone
    @milestone = IfaPlanMilestone.find_by_public_id(params[:ifa_plan_milestone_id])
  end

  def set_remark
    @remark = IfaPlanRemark.find_by_public_id(params[:ifa_plan_remark_id])
  end

  def set_strand
    @strand = ActStandard.find_by_public_id(params[:act_standard_id]) rescue nil
    if @strand.nil?
      @strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    end
  end

  def set_range
    @range = ActScoreRange.find_by_public_id(params[:act_score_range_id])
  end

  def set_student
    @current_student = User.find_by_public_id(params[:student_id]) rescue nil
  end

  def current_student
    @current_student = User.find_by_id(params[:student_id]) rescue nil
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
    if @current_range && @current_strand && @current_standard
      @benchmarks = @current_standard.benchmarks_for_strand_range(@current_strand, @current_range)
      @improvements = @current_standard.improvements_for_strand_range(@current_strand, @current_range)
      @evidences = @current_standard.evidence_for_strand_range(@current_strand, @current_range)
    else
      @benchmarks = []
      @improvements = []
      @evidences = []
    end
  end

  def milestone_properties
    @user_plan = @current_milestone.plan
    @current_strand = @current_milestone.strand
    @ranges = strand_ranges(@current_milestone.strand)
  end

  def milestone_destroy?(milestone,force)
    @user_plan = @current_milestone.plan
    @strand = @current_milestone.strand
    @ranges = strand_ranges(@current_milestone.strand)
    if milestone.description.nil? || milestone.description.empty? || force
      milestone.destroy
    end
  end

end
