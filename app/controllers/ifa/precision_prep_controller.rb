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

  def metrics_guardian
    @metrics_org_list = []
    @metrics_org_list << @current_organization
    @guardian_organization = @current_organization
    @students = @guardian_organization.current_students_with_guardian
    @notify_count = @students.map{|s| s.guardian_notify_count}.sum
    @inquiry_count = @students.map{|s| s.guardian_inquiry_count}.sum
    @no_guardian = @guardian_organization.current_students.size - @students.size
    render :partial => "/ifa/precision_prep/manage_metrics", :locals=>{:s_metric=>false, :t_metrics=>false, :g_metrics=>true}
  end

  private

  def current_student
    @current_student = User.find_by_public_id(params[:student_id]) rescue nil
  end

  def current_guardian
    @current_guardian = UserGuardian.find_by_public_id(params[:guardian_id]) rescue nil
  end
end
