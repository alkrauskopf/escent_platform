class Ifa::PrecisionPrepController < Ifa::ApplicationController
  layout "precision_prep"

  before_filter :current_student


  def interest_student
    current_student
    @notify_success = (@current_student && @current_organization) ? true : false
    if !@notify_success
      @err_msgs = []
      if @current_student.nil?
        @err_msgs << 'No Student Identified'
      end
      if @current_organization.nil?
        @err_msgs << 'No Organization Identified'
      end
    else
      PrecisionPrepMailer.prep_student_inquiry(@current_student, @current_organization, request.host_with_port).deliver
    end
  end

  def interest_guardian
    current_guardian
    @current_student = @current_guardian.nil? ? nil : (@current_guardian.user ? @current_guardian.user : nil)
    @notify_success = (@current_student && @current_organization && @current_guardian) ? true : false
    if !@notify_success
      @err_msgs = []
      if @current_student.nil?
        @err_msgs << 'No Student Identified'
      end
      if @current_guardian.nil?
        @err_msgs << 'No Guardian Identified'
      end
      if @current_organization.nil?
        @err_msgs << 'No Organization Identified'
      end
    else
      PrecisionPrepMailer.prep_guardian_inquiry(@current_student, @current_guardian, @current_organization, request.host_with_port).deliver
      @current_guardian.increment_inquiry
    end
  end

  def metrics_close
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metrics=>false, :t_metrics=>false, :g_metrics=>false}
  end

  def guardian_filter
    @metric_organization = Organization.find_by_id(params[:entity_id])
    guardian_metrics
    render :partial => 'metrics_guardian'
  end

  def metrics_guardian
    @metric_organization = @current_organization
    guardian_metrics
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metrics=>false, :t_metrics=>false, :g_metrics=>true}
  end

  def teacher_filter
    @metric_organization = Organization.find_by_id(params[:entity_id])
    teacher_metrics
    render :partial => 'metrics_teacher'
  end

  def metrics_teacher
    @metric_organization = @current_organization
    teacher_metrics
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metrics=>false, :t_metrics=>true, :g_metrics=>false}
  end

  def student_filter
    @metric_organization = Organization.find_by_id(params[:entity_id])
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    student_metrics(@current_subject)
    render :partial => 'metrics_student'
  end

  def student_subject_filter
    @metric_organization = Organization.find_by_id(params[:metric_org_id]) rescue nil
    @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    student_metrics(@current_subject)
    render :partial => 'metrics_student'
  end

  def metrics_student
    @metric_organization = @current_organization
    @current_subject = ActSubject.plannable[2]
    student_metrics(@current_subject)
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metrics=>true, :t_metrics=>false, :g_metrics=>false}
  end

  private

  def current_student
    @current_student = User.find_by_public_id(params[:student_id]) rescue nil
  end

  def current_guardian
    @current_guardian = UserGuardian.find_by_public_id(params[:guardian_id]) rescue nil
  end

  def guardian_metrics
    @metrics_org_list = []
    if @current_organization == @current_provider
      @metrics_org_list = @current_organization.provided_app_orgs(@current_application, false)
    else
      @metrics_org_list << @metric_organization
    end
    @students = @metric_organization.current_ifa_students_with_guardian
    @notify_count = @students.map{|s| s.guardian_notify_count}.sum
    @inquiry_count = @students.map{|s| s.guardian_inquiry_count}.sum
    @no_guardian = @metric_organization.current_ifa_students.size - @students.size
  end

  def teacher_metrics
    @metrics_org_list = []
    if @current_organization == @current_provider
      @metrics_org_list = @current_organization.provided_app_orgs(@current_application, false)
    else
      @metrics_org_list << @metric_organization
    end
    @teachers = @metric_organization.ifa_classroom_teachers
    @teachers_with_remark = @teachers.select{|t| !t.ifa_plan_remarks.empty?}
    @remark_count = @teachers.map{|t| t.ifa_plan_remarks.size}.sum
    @no_remarks = @teachers.size - @teachers_with_remark.size
    @student_list = {}
    @teachers.each do |teacher|
      @student_list[teacher] = teacher.ifa_plan_remarks.empty? ? 'No Plan Remarks Made' : teacher.remarked_student_list
    end
  end

  def student_metrics(subject)
    @metrics_org_list = []
    if @current_organization == @current_provider
      @metrics_org_list = @current_organization.provided_app_orgs(@current_application, false)
    else
      @metrics_org_list << @metric_organization
    end
    @students = @metric_organization.current_ifa_students
    @student_list = {}
    @student_list['plans'] = 0
    @student_list['wm_yes'] = 0
    @student_list['am_yes'] = 0
    @student_list['e_yes'] = 0
    @student_list['workstones'] = 0
    @student_list['achievestones'] = 0
    @student_list['evidence'] = 0
    @students.each do |student|
      plan = student.ifa_plan_for(subject)
      @student_list['p'+student.id.to_s] = plan.nil? ? 0 : 1
      @student_list['m'+student.id.to_s] = plan.nil? ? 0 : plan.milestones.size
      @student_list['wm'+student.id.to_s] = plan.nil? ? 0 : plan.milestones.not_achieved.size
      @student_list['am'+student.id.to_s] = plan.nil? ? 0 : plan.milestones.achieved.size
      @student_list['e'+student.id.to_s] = plan.nil? ? 0 :plan.evidence_list.size
      @student_list['plans'] += plan.nil? ? 0 : 1
      @student_list['workstones'] += @student_list['m'+student.id.to_s] - @student_list['am'+student.id.to_s]
      @student_list['achievestones'] += @student_list['am'+student.id.to_s]
      @student_list['evidence'] += @student_list['e'+student.id.to_s]
      @student_list['wm_yes'] += @student_list['wm'+student.id.to_s] == 0 ? 0 : 1
      @student_list['am_yes'] += @student_list['am'+student.id.to_s] == 0 ? 0 : 1
      @student_list['e_yes'] += @student_list['e'+student.id.to_s] == 0 ? 0 : 1
    end
    @student_list['pct_plans'] = @students.empty? ? 0 : (100.0*(@student_list['plans'].to_f/@students.size.to_f)).to_i
    @student_list['pct_wm'] = @students.empty? ? 0 : (100.0*(@student_list['wm_yes'].to_f/@students.size.to_f)).to_i
    @student_list['pct_am'] = @students.empty? ? 0 : (100.0*(@student_list['am_yes'].to_f/@students.size.to_f)).to_i
    @student_list['pct_e'] = @students.empty? ? 0 : (100.0*(@student_list['e_yes'].to_f/@students.size.to_f)).to_i
  end
end
