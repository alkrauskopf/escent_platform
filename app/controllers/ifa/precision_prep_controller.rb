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
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metric=>false, :t_metrics=>false, :g_metrics=>false}
  end

  def guardian_filter
    @metric_organization = Organization.find_by_id(params[:entity_id])
    guardian_metrics
    render :partial => 'metrics_guardian'
  end

  def metrics_guardian
    @metric_organization = @current_organization
    guardian_metrics
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metric=>false, :t_metrics=>false, :g_metrics=>true}
  end

  def teacher_filter
    @metric_organization = Organization.find_by_id(params[:entity_id])
    teacher_metrics
    render :partial => 'metrics_teacher'
  end

  def metrics_teacher
    @metric_organization = @current_organization
    teacher_metrics
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metric=>false, :t_metrics=>true, :g_metrics=>false}
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
end
