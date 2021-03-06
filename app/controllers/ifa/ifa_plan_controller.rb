class Ifa::IfaPlanController < Ifa::ApplicationController
#  helper :all # include all helpers, all the time

  layout "ifa_submission", :only=>[:evidence_edit, :evidence_update, :student_plan]

 # before_filter :set_ifa, :except=>[]
 # before_filter :current_app_enabled_for_current_org?, :except=>[]
  before_filter :current_user?
  before_filter :current_user_teacher?, :only=>[]
  before_filter :current_user_app_admin?, :only=>[]
  before_filter :current_user_app_authorized?, :only=>[:index]
  before_filter :current_user_app_admin?, :only=>[]
 # before_filter :current_ifa_options
  before_filter :current_app_superuser, :only=>[:index]
  before_filter :clear_notification, :except => [:take_assessment]
  before_filter :increment_app_views, :only=>[:index]

  def student_plan
    current_subject
    current_student
    @current_plan = @current_student.ifa_plan_for(@current_subject)
    plan_benchmarks
    @show_db = 'Show'
    @show_gd = 'Show'
    if @current_plan.nil?
      @current_plan = IfaPlan.new
      @current_plan.act_subject_id = @current_subject.id
      @current_student.ifa_plans << @current_plan
      @current_plan = @current_student.ifa_plan_for(@current_subject)
      IfaPlanMetric.plan(@current_student, @current_subject, @current_standard, 'New')
    end
    @show = 'Yes'
    if @current_plan.milestones.empty?
      create_student_dashboard(@current_student, @current_subject, @current_standard)
      @show_db = 'Hide'
    end
  end

  def student_plan_dashboard
    current_subject
    current_student
    @current_plan = @current_student.ifa_plans.for_subject(@current_subject).empty? ? nil : @current_student.ifa_plans.for_subject(@current_subject).first
    @show = params[:show]
    @show_db = params[:show_db] == 'Show' ? 'Hide': 'Show'
    create_student_dashboard(@current_student, @current_subject, @current_standard)
    render :partial => "/ifa/ifa_plan/student_plan_dashboard", :locals=>{}
  end

  def student_guardian
    current_student
    @show_gd = params[:show_gd] == 'Show' ? 'Hide': 'Show'
    render :partial => "/ifa/ifa_plan/student_plan_guardian", :locals=>{}
  end

  def create_student_dashboard(student, subject, standard)
    @entity_dashboard = student.last_ifa_dashboard(subject)
    dashboard_cell_hashes(@entity_dashboard, subject, standard, :student=>'Y')
    dashboard_milestone_links(student, subject, standard)
    entity_header_info(@entity_dashboard, subject, standard)
 #   dashboard_header_info(@entity_dashboard, subject, standard)
 #   dashboardable_submissions(@entity_dashboard, subject)
    db_users = []
    db_users << @current_student
    dashboard_plan_markers(db_users, subject, standard)
  end

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
    current_subject
    current_student
    new_plan = IfaPlan.new(params[:ifa_plan])
    new_plan.act_subject_id = @current_subject.id
    @current_student.ifa_plans << new_plan
    PrecisionPrepMailer.plan_created_student(@current_student, new_plan, request.host_with_port).deliver
    PrecisionPrepMailer.plan_created_guardian(@current_student, new_plan, request.host_with_port).deliver
    redirect_to ifa_plan_student_path(:organization_id => @current_organization, :act_subject_id => @current_subject.id, :student_id=> @current_student.id)
  end

  def plan_create_x
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
    current_subject
    current_student
    current_plan
    @show_gd = 'Show'
    if @current_plan
      @current_plan.update_attributes(:needs=>params[:needs],:goals=>params[:goals])
    #  PrecisionPrepMailer.plan_created_student(@current_student, @current_plan, request.host_with_port).deliver
    #  PrecisionPrepMailer.plan_created_guardian(@current_student, @current_plan, request.host_with_port).deliver
    else
      @current_plan = IfaPlan.create(:act_subject_id => @current_subject.id, :needs=>params[:needs], :goals=>params[:goals])
      @current_student.ifa_plans << @current_plan
      PrecisionPrepMailer.plan_created_student(@current_student, @current_plan, request.host_with_port).deliver
      PrecisionPrepMailer.plan_created_guardian(@current_student, @current_plan, request.host_with_port).deliver
    end
    plan_benchmarks
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @current_student.ifa_plan_subject(@current_subject), :student => @current_student, :subject => @current_subject, :show_form => false}
  end

  def plan_show_form
    current_subject
    @current_student = @current_user
    plan_benchmarks
    @user_plan = @current_user.ifa_plan_subject(@current_subject)
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_user, :subject => @current_subject, :show_form => true}
  end

  def plan_update_cancel
    current_subject
    current_student
    plan_benchmarks
    @user_plan = @current_student.ifa_plan_subject(@current_subject) rescue nil
    render :partial => "/ifa/ifa_plan/manage_subj_plan", :locals=>{:student_plan => @user_plan, :student => @current_student, :subject => @current_subject, :show_form => @current_user.show_ifa_plan_form?(@current_subject)}
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
    current_milestone
    @current_range = @current_milestone.range
    @current_strand = @current_milestone.strand
    benchmarks_improvements
    @current_plan=@current_milestone.plan
    plan_benchmarks
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@current_milestone.plan, :strand => @current_strand,
                                                                    :milestone_form => 'Change',
                                                                     :ranges => strand_ranges(@current_milestone.strand)}
  end

  def milestone_update
    current_strand
    current_range
    current_milestone
    set_plan
    if @current_milestone
      prev_teacher_id = @current_milestone.teacher_id.nil? ? '0' : @current_milestone.teacher_id.to_s
      if @current_milestone.update_attributes(:description=> params[:description], :teacher_id => params[:teacher_id]=='0' ? nil : params[:teacher_id].to_i)
        if (prev_teacher_id != params[:teacher_id]) && (params[:teacher_id] != '0')
          PrecisionPrepMailer.milestone_new_teacher(@current_user, new_milestone_teacher, @current_milestone, request.host_with_port).deliver
        end
      end
    end
    set_plan
    plan_benchmarks
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                    :milestone_form => 'No', :ranges => @user_plan.ranges(@current_standard)}
  end

  def milestone_update_dashboard
    current_strand
    current_range
    set_plan
    if new_milestone?
      @current_milestone = IfaPlanMilestone.new
      @current_milestone.act_score_range_id = @current_range.id
      @current_milestone.act_standard_id = @current_strand.id
      @current_milestone.description = params[:ifa_milestone][:description]
      @current_milestone.teacher_id = params[:ifa_milestone][:teacher_id] == '0' ? nil : params[:ifa_milestone][:teacher_id].to_i
      @current_milestone.achieve_date = Time.now
      @user_plan.milestones << @current_milestone
      PrecisionPrepMailer.milestone_created_student(@current_user, @current_milestone, request.host_with_port).deliver
      PrecisionPrepMailer.milestone_created_guardian(@current_user, @current_milestone, request.host_with_port).deliver
      IfaPlanMetric.milestone(@current_milestone, 'New')
      if @current_milestone.teacher
        PrecisionPrepMailer.milestone_created_teacher(@current_user, @current_milestone.teacher, @current_milestone, request.host_with_port).deliver
      else
        PrecisionPrepMailer.milestone_created_teacher_group(@current_user, @user_plan.relevant_teachers(@current_organization), @current_milestone, request.host_with_port).deliver
      end
    end
    redirect_to ifa_plan_student_path(:organization_id=>@current_organization, :student_id => @current_user.id,
                                      :act_subject_id => @current_strand.act_subject.id)
  end

  def milestone_update_cancel
    set_plan
    current_strand
    plan_benchmarks
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                    :milestone_form => 'No', :ranges => @user_plan.ranges(@current_standard)}
  end

  def milestone_destroy
    current_milestone
    current_strand
    set_plan
    @current_milestone.destroy
    IfaPlanMetric.milestone(@current_milestone, 'Destroy')
    plan_benchmarks
    render :partial => "/ifa/ifa_plan/strand_milestones", :locals=>{:plan=>@user_plan, :strand => @current_strand,
                                                                    :milestone_form => 'No', :ranges => @user_plan.ranges(@current_standard)}
  end

  def milestone_achieved
    current_milestone
    toggle = @current_milestone.achieved? ? 'Undo' : 'Do'
    @current_milestone.update_attributes(:is_achieved=>!@current_milestone.is_achieved, :achieve_date => Time.now)
    @current_plan=@current_milestone.plan
    IfaPlanMetric.milestone_achieved(@current_milestone, toggle)
    plan_benchmarks
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => 'No',
                                                                  :milestone_benchmarks => @plan_benchmarks[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_suggestions => @plan_suggestions[hash_key(@current_milestone.range, @current_milestone.strand)],
                                                                  :milestone_examples => @plan_examples[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_evidence => @plan_evidence[hash_key(@current_milestone.range, @current_milestone.strand)]}
  end

  def milestone_achieve_toggle
    set_milestone
    @milestone.update_attributes(:is_achieved=>!@milestone.is_achieved, :achieve_date => Time.now)
    @current_plan=@milestone.plan
    plan_benchmarks
    render :partial =>  "/ifa/ifa_plan/teacher_show_milestone", :locals=>{:milestone => @milestone,
                                                                          :milestone_benchmarks => @plan_benchmarks[hash_key(@milestone.range, @milestone.strand)], :milestone_suggestions => @plan_suggestions[hash_key(@milestone.range, @milestone.strand)],
                                                                          :milestone_examples => @plan_examples[hash_key(@milestone.range, @milestone.strand)], :milestone_evidence => @plan_evidence[hash_key(@milestone.range, @milestone.strand)]}
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

  def plan_student_review
    current_subject
    current_student
    if params[:show] == 'Create'
      @user_plan = IfaPlan.new
    else
      @user_plan = @current_student.ifa_plan_subject(@current_subject) rescue nil
    end
    @remarks = @user_plan.nil? ? [] : @user_plan.remarks
    @milestones= @user_plan.nil? ? nil : @user_plan.ifa_plan_milestones.by_last_updated
    render :partial => "/ifa/ifa_plan/student_review_plan", :locals=>{:student_plan => @user_plan, :student => @current_student, :subject => @current_subject, :show => params[:show]}
  end

  def plan_student_review_close
    current_subject
    current_student
    @user_plan = @current_student.ifa_plan_subject(@current_subject) rescue nil
    render :partial => '/ifa/ifa_plan/student_review_plan', :locals=>{:student_plan => @user_plan, :student => @current_student, :subject => @current_subject, :show => 'No'}
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
    PrecisionPrepMailer.remark_student(@user_plan.user, @user_plan, new_remark.remarks, @current_user, request.host_with_port).deliver
    PrecisionPrepMailer.remark_guardian(@user_plan.user, @user_plan, new_remark.remarks, @current_user, request.host_with_port).deliver
    IfaPlanMetric.remark(@user_plan.user, @user_plan.subject_area, @current_standard, 'New')
    render :partial =>  "/ifa/ifa_plan/teacher_remarks", :locals=>{:plan=> @user_plan, :remarks => @user_plan.remarks, :classroom => @classroom, :show_form=>false}
  end

  def plan_teacher_remark_destroy
    set_plan
    set_classroom
    set_remark
    @remark.destroy
    IfaPlanMetric.remark(@current_student, @current_subject, @current_standard, 'Destroy')
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
    @current_plan=@current_milestone.plan
    plan_benchmarks
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => evidence,
                                                                  :milestone_benchmarks => @plan_benchmarks[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_suggestions => @plan_suggestions[hash_key(@current_milestone.range, @current_milestone.strand)],
                                                                  :milestone_examples => @plan_examples[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_evidence => @plan_evidence[hash_key(@current_milestone.range, @current_milestone.strand)]}
  end

  def evidence_destroy
    current_evidence
    @current_milestone = @current_evidence.milestone
    @current_evidence.destroy
    IfaPlanMetric.evidence_metric(@current_milestone, 'Destroy')
    render :partial => "/ifa/ifa_plan/evidence_list", :locals => {:milestone => @current_milestone}
  end

  def evidence_cancel
    current_milestone
    @current_plan=@current_milestone.plan
    plan_benchmarks
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => 'No',
                                                                  :milestone_benchmarks => @plan_benchmarks[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_suggestions => @plan_suggestions[hash_key(@current_milestone.range, @current_milestone.strand)],
                                                                  :milestone_examples => @plan_examples[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_evidence => @plan_evidence[hash_key(@current_milestone.range, @current_milestone.strand)]}
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
        IfaPlanMetric.evidence_metric(@current_milestone, 'New')
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
    @current_plan=@current_milestone.plan
    plan_benchmarks
    render :partial =>  "/ifa/ifa_plan/show_milestone", :locals=>{:milestone => @current_milestone, :evidence_form => 'No',
                                                                  :milestone_benchmarks => @plan_benchmarks[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_suggestions => @plan_suggestions[hash_key(@current_milestone.range, @current_milestone.strand)],
                                                                  :milestone_examples => @plan_examples[hash_key(@current_milestone.range, @current_milestone.strand)], :milestone_evidence => @plan_evidence[hash_key(@current_milestone.range, @current_milestone.strand)]}
  end

  def evidence_list
    current_milestone
    render :partial => "/ifa/ifa_plan/evidence_list", :locals => {:milestone => @current_milestone}
  end

  def show_html
    current_evidence
    render :layout => "assessment"
  end

  def plan_review_dashboard
    current_subject
    if params[:entity_class] == "Organization"
      entity = Organization.find_by_id(params[:entity_id]) rescue nil
      students = entity.nil? ? [] : (entity == @current_provider ? entity.precision_prep_provider_students
      : entity.classrooms.for_subject(@current_subject).precision_prep_students)
    else
      entity = Classroom.find_by_id(params[:entity_id]) rescue nil
      students = entity.participants
    end
    dashboard_entity_students(params[:db_type], @current_subject, students, entity)
    db_view = params[:db_view] == "View" ? true:false
    render :partial => "/ifa/ifa_plan/teacher_review_dashboard", :locals=>{:subject=> @current_subject, :db_type => params[:db_type], :entity => entity, :db_view => db_view }
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
    @current_milestone = IfaPlanMilestone.find_by_id(params[:ifa_plan_milestone_id]) rescue nil
  end

  def current_range
    @current_range = ActScoreRange.find_by_id(params[:act_score_range_id])
  end

  def current_strand
    @current_strand = ActStandard.find_by_id(params[:act_standard_id])
  end

  def new_milestone?
    params[:function] && (params[:function] == 'New' || params[:function] == 'Add' || params[:function] == 'Add Milestone')
  end

  def milestone_function
    params[:function]
  end

  def new_milestone_teacher
    User.find_by_id(params[:teacher_id]) rescue nil
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
    @current_plan = @user_plan
  end
  def current_plan
    @current_plan = IfaPlan.find_by_id(params[:ifa_plan_id]) rescue nil
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
      @examples = @current_standard.examples_for_strand_range(@current_strand, @current_range)
    else
      @benchmarks = []
      @improvements = []
      @evidences = []
      @examples = []
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

  def dashboard_entity_students(db_type, subject, students, entity)
    @plan_dashboard = {}
    @plan_dashboard['none'] = []
    @current_standard.act_score_ranges.active.for_subject(subject).each do |level|
      @current_standard.act_standards.active.for_subject(subject).each do |strand|
        hashkey = level.id.to_s + strand.id.to_s
        @plan_dashboard[hashkey] = []
      end
    end
    students.each do |student|
      milestones = student.ifa_plan_for(subject).nil? ? [] : (db_type == 'M' ? student.ifa_plan_for(subject).milestones.not_achieved : student.ifa_plan_for(subject).milestones.achieved)
      if milestones.empty?
        @plan_dashboard['none']<<student
      else
        milestones.map{|m| (m.range.id.to_s + m.strand.id.to_s)}.uniq.each do |hashkey|
          if @plan_dashboard[hashkey]
            @plan_dashboard[hashkey]<<student
          end
        end
      end
    end
    @active_strands = ActStandard.all_for_standard_and_subject(@current_standard, subject).active
    @active_levels = ActScoreRange.for_standard_and_subject(@current_standard, @current_subject)
    @plan_dashboard['header1'] = entity.name + ' | ' + subject.name
    @plan_dashboard['type'] = (db_type == 'M' ? 'Work-In-Process' : 'Milestone Mastery')
    @plan_dashboard['header2'] = (db_type == 'M' ? 'With No Milestones' : 'With No Achievements')
  end

  def plan_benchmarks
    @plan_benchmarks = {}
    @plan_suggestions = {}
    @plan_evidence = {}
    @plan_examples = {}
    if !@current_plan.nil?
      @current_plan.milestones.each do |milestone|
        hashkey = hash_key(milestone.range, milestone.strand)
        if @current_plan.remarkable?(@current_user)
          @plan_benchmarks[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.benchmark(@current_standard))
          @plan_suggestions[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.improvement(@current_standard))
          @plan_examples[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.example(@current_standard))
          @plan_evidence[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.evidence(@current_standard))
        else
          @plan_benchmarks[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.benchmark(@current_standard), :student=>'Y')
          @plan_suggestions[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.improvement(@current_standard), :student=>'Y')
          @plan_examples[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.example(@current_standard), :student=>'Y')
          @plan_evidence[hashkey]=@current_standard.active_benches_strand_range(milestone.strand, milestone.range, ActBenchType.evidence(@current_standard), :student=>'Y')
        end
      end
    end
  end

  def hash_key(range, strand)
    if !range.nil? && !strand.nil?
      key = range.id.to_s + strand.id.to_s
    else
      key = ''
    end
    key
  end
end

