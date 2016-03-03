class Apps::TeacherAssessController < Site::ApplicationController

  helper :all # include all helpers, all the time  

 layout "site", :except =>[:teacher_dashboard, :classroom_dashboard, :subject_classrooms]
  
 #  
  def index

  initialize_parameters
  CoopApp.ita.increment_views
  @classroom_list = @current_organization.classrooms.active.sort{|a,b| b.act_subject.name <=> a.act_subject.name}
  @teacher_list = @classroom_list.collect{|cl| cl.leaders}.flatten.uniq.sort_by{|teacher|[teacher.last_name]} rescue nil
  @t_name = []
  @t_metrics = []  
  @metric_header = []
  @metric_header_hover = []
  @num_tchr_metrics = @current_user.tchr_option.tchr_metrics.for_teacher.size rescue 0
  @num_clsrm_metrics = @current_user.tchr_option.tchr_metrics.for_classroom.size rescue 0
  @teacher_list.each_with_index do |t,idx|
    @t_name[idx] = t.last_name.upcase + ", " + t.first_name.titleize
    @t_metrics[idx] = []
    if @num_tchr_metrics > 0
      @current_user.tchr_option.tchr_metrics.for_teacher.each_with_index do |var,vdx|
      
      @metric_header[vdx] = var.abbrev
      @metric_header_hover[vdx] = "<span style='text-align:center'><strong><u>" + var.name.titleize +  "</u></strong></span><span style='text-align:center'>" + var.description.humanize + "</span>"
      vdx_metric = 0
      if var.abbrev == "RC"
         vdx_metric = t.contents.size rescue 0
      end
      
      if var.abbrev == "CC"
        vdx_metric = t.lead_classrooms.select{|clsrm| clsrm.organization == @current_organization}.size rescue 0
      end
      
      if var.abbrev == "SC"
         vdx_metric =  t.sc(@current_organization).size
      end
      
      if var.abbrev == "OC"
         vdx_metric =  t.oc(@current_organization).size
      end
      
      if var.abbrev == "TC"
         vdx_metric =  t.tc(@current_organization).size
      end    
      
      if var.abbrev == "RV"
        vdx_metric = t.rv
      end 
      
      if var.abbrev == "RU"
        vdx_metric = t.ru(@current_organization).size
      end      
      
      if var.abbrev == "OTR"
        vdx_metric = t.otr(@current_organization).size
      end      
      
      if var.abbrev == "SMS"
        vdx_metric = t.ms(@start_date, @end_date)
      end        
      
      if var.abbrev == "SMR"
        vdx_metric = t.mr(@start_date, @end_date)
      end 
      
      if var.abbrev == "SAT"
        vdx_metric = t.sat(@start_date, @end_date)       
      end      
      
      if var.abbrev == "SAR"
        vdx_metric = t.sar(@start_date, @end_date)       
      end      
      
      if var.abbrev == "ASML-M"
        vdx_metric = t.asml(1,@start_date, @end_date, @current_standard, @current_organization)
      end
      
      if var.abbrev == "ASML-E"
        vdx_metric = t.asml(2,@start_date, @end_date, @current_standard, @current_organization)
      end      
      
      if var.abbrev == "ASML-R"
        vdx_metric = t.asml(3,@start_date, @end_date, @current_standard, @current_organization)
      end
      
      if var.abbrev == "ASML-S"
        vdx_metric = t.asml(4,@start_date, @end_date, @current_standard, @current_organization)
      end   
      
      if var.abbrev == "HC"
         vdx_metric =  t.hc(@start_date, @end_date, @current_organization).size     
      end      
      
      if var.abbrev == "CTC"
         vdx_metric =  t.ctc(@start_date, @end_date, @current_organization).size      
      end
      
      if var.abbrev == "CRU"
        vdx_metric = t.cru(@current_organization).size     
      end
       
      if var.abbrev == "LQC"
         vdx_metric =  t.lqc(@start_date, @end_date).size      
     end 
       
      if var.abbrev == "LAC"
         vdx_metric =  t.lac(@start_date, @end_date).size      
     end 
       
      if var.abbrev == "CQC"
         vdx_metric =  t.cqc(@start_date, @end_date).size      
     end 
       
      if var.abbrev == "CAC"
         vdx_metric =  t.cac(@start_date, @end_date).size      
     end 
          
    @t_metrics[idx] << vdx_metric
    end      
  end
  end  
  @avail_tchr_metrics = TchrMetric.find(:all, :conditions=>["for_teacher"]) - @current_user.tchr_option.tchr_metrics.for_teacher rescue nil
  @avail_clsrm_metrics = TchrMetric.find(:all, :conditions=>["for_classroom"]) - @current_user.tchr_option.tchr_metrics.for_classroom rescue nil
  end

  def teacher_dashboard

  initialize_parameters

  @classroom_list = @current_organization.classrooms.active.sort_by{|clsrm|[clsrm.act_subject.name]}
  @teacher_list = @classroom_list.collect{|cl| cl.leaders}.flatten.uniq.sort_by{|teacher|[teacher.last_name]}
  @resources_contributed = @current_organization.contents.active.size
  @resource_contributors = @current_organization.contents.active.collect{|c| c.user_id}.uniq.size
  @resources_per_contributor = @resources_contributed/@resource_contributors
  @teacher_resources = @teacher.contents 
  @teacher_period_resources =  @teacher_resources.select{|rsrc| rsrc.created_at >= @start_date && rsrc.created_at <= @end_date}
  @teacher_classrooms = @teacher.lead_classrooms.select{|clsrm| clsrm.organization == @current_organization}
  @assessments_taken = ActSubmission.find(:all, :conditions => ["organization_id = ? && created_at >= ? && created_at <= ?", @current_organization.id, @start_date, @end_date]) rescue nil
  @assessment_teachers = @assessments_taken.collect{|a| a.teacher_id}.uniq.size
  @assessments_per_teacher = @assessments_taken.size/@assessment_teachers
  @teacher_assessments = ActSubmission.find(:all, :conditions => ["teacher_id = ? && created_at >= ? && created_at <= ?", @teacher.id, @start_date, @end_date]) rescue nil
  @teacher_msgs_sent = Message.find(:all, :conditions=>["sender = ? && created_at >= ? && created_at <= ?", @teacher.full_name, @start_date, @end_date]) rescue nil
  @teacher_msgs_received = Message.find(:all, :conditions=>["user_id = ? && created_at >= ? && created_at <= ?", @teacher.id, @start_date, @end_date])rescue nil
  @teacher_assessments_finalized = @teacher_assessments.select{|ass| ass.date_finalized >= @start_date && ass.date_finalized <= @end_date} rescue nil
  @teacher_students = @teacher.sc(@current_organization).size rescue 0
  @teacher_observers = @teacher.oc(@current_organization).size rescue 0
  @teacher_used_resources = @teacher.ru(@current_organization).size rescue 0

  @teacher_monthly_resources = []
  @teacher_monthly_msgs_sent = []
  @teacher_monthly_msgs_received = []
  @teacher_monthly_assessments = []
  @teacher_monthly_assessments_finalized = []
  @window = []
  @m_name = []
  @w_metrics =[]
  @metric_header_hover = []
  @tchr_metrics = TchrMetric.find(:all, :conditions=>["for_teacher && by_month"]) rescue nil
  if @tchr_metrics 

    @tchr_metrics.each_with_index do |var,vdx|
      @m_name[vdx] = var.abbrev
      @metric_header_hover[vdx] = "<span style='text-align:center'><strong><u>" + var.name.titleize +  "</u></strong></span><span style='text-align:center'>" + var.description.humanize + "</span>"
      @w_metrics[vdx] = []      

      wdx = 0
      window_start = @start_date
      window_end = window_start.end_of_month
      until window_start > @end_date
      wdx_metric = 0        
      
        if var.abbrev == "RC"
         wdx_metric = @teacher_resources.select{|rsrc| rsrc.created_at >= window_start && rsrc.created_at <= window_end}.size rescue 0
        end
      
        if var.abbrev == "SMS"
          wdx_metric = @teacher.ms(window_start, window_end)
        end        
      
        if var.abbrev == "SMR"
          wdx_metric = @teacher.mr(window_start, window_end)
        end  
      
        if var.abbrev == "SAT"
          wdx_metric = @teacher.sat(window_start, window_end)       
        end      
      
        if var.abbrev == "SAR"
          wdx_metric = @teacher.sar(window_start, window_end)       
        end      
      
        if var.abbrev == "ASML-M"
          wdx_metric = @teacher.asml(1, window_start, window_end, @current_standard, @current_organization)
        end
      
        if var.abbrev == "ASML-E"
          wdx_metric = @teacher.asml(2, window_start, window_end, @current_standard, @current_organization)
        end      
      
        if var.abbrev == "ASML-R"
          wdx_metric = @teacher.asml(3, window_start, window_end, @current_standard, @current_organization)
        end
      
        if var.abbrev == "ASML-S"
          wdx_metric = @teacher.asml(4, window_start, window_end, @current_standard, @current_organization)
        end   
      
        if var.abbrev == "HC"
          wdx_metric = @teacher.hc(window_start, window_end, @current_organization).size     
        end      
      
        if var.abbrev == "CTC"
          wdx_metric = @teacher.ctc(window_start, window_end, @current_organization).size      
        end
       
        if var.abbrev == "LQC"
          wdx_metric =  @teacher.lqc(window_start, window_end).size      
        end 
       
        if var.abbrev == "LAC"
          wdx_metric =  @teacher.lac(window_start, window_end).size      
        end 
       
        if var.abbrev == "CQC"
          wdx_metric =  @teacher.cqc(window_start, window_end).size      
        end 
       
        if var.abbrev == "CAC"
          wdx_metric =  @teacher.cac(window_start, window_end).size     
        end        
      
      @window[wdx] = window_start
      window_start += 1.month
      window_start = window_start.beginning_of_month
      window_end = window_start.end_of_month
      if window_end > @end_date
        window_end = @end_date
      end
      wdx += 1
      @w_metrics[vdx] << wdx_metric
      end
    end
   end
  end

  def subject_classrooms

  initialize_parameters
    @classroom_list = @current_organization.classrooms.active.select{|cl| cl.act_subject_id == @current_subject.id}.sort_by{|c| c.course_name} rescue []
    @c_name = []
    @c_tchrs = []
    @c_metrics = []  
    @metric_header = []
    @metric_header_hover = []
    @num_clsrm_metrics = @current_user.tchr_option.tchr_metrics.for_classroom.size rescue 0
    @classroom_list.each_with_index do |c,idx|
    @c_name[idx] = c.course_name.upcase
    @c_tchrs[idx]= c.leaders.collect{|l| l.last_name}.join("/")
    @c_metrics[idx] = []
    if @num_clsrm_metrics > 0
      @current_user.tchr_option.tchr_metrics.for_classroom.each_with_index do |var,vdx|
      
      @metric_header[vdx] = var.abbrev
      @metric_header_hover[vdx] = "<span style='text-align:center'><strong><u>" + var.name.titleize +  "</u></strong></span><span style='text-align:center'>" + var.description.humanize + "</span>"
      vdx_metric = 0
      if var.abbrev == "TC"
         vdx_metric = c.topics.active.size rescue 0
      end
      
      if var.abbrev == "SC"
        vdx_metric = c.participants.size rescue 0
      end
      
      if var.abbrev == "OC"
        vdx_metric = c.observers.size rescue 0
      end
      
      if var.abbrev == "RU"
         vdx_metric =  c.resources.size rescue 0
      end
      
      if var.abbrev == "OTR"
        vdx_metric = c.otr.size
      end        

      if var.abbrev == "SAT"
        vdx_metric = c.act_submissions.select{|ass| ass.created_at >= @start_date && ass.created_at <= @end_date}.size rescue 0      
      end      
      
      if var.abbrev == "SAR"
        vdx_metric = c.act_submissions.select{|ass| ass.date_finalized >= @start_date && ass.date_finalized <= @end_date}.size rescue 0     
      end      
      
      if var.abbrev == "CML"
        vdx_metric = c.cml(@start_date, @end_date, @current_standard)
      end
      
      if var.abbrev == "HC"
        vdx_metric = c.homeworks.select{|hw| hw.created_at >=@start_date && hw.created_at<= @end_date}.size rescue 0      
      end      
      
      if var.abbrev == "CTC"
         vdx_metric =  c.discussion_comments.select{|com| com.created_at>= @start_date && com.created_at <= @end_date}.size rescue 0     
      end
      
      if var.abbrev == "CRU"
        vdx_metric = c.resources.select{|r| r.organization.organization_type.name == "Commercial Partner"}.size   rescue 0  
      end
      
      if var.abbrev == "MSGX"
         vdx_metric = c.messages.select{|ms| ms.created_at >=@start_date && ms.created_at<= @end_date}.size rescue 0      
      end
      
      if var.abbrev == "CQU"
         class_assesses = c.act_assessment_classrooms.select{|ca| ca.created_at >=@start_date && ca.created_at<= @end_date}
         assessments = class_assesses.collect{|a| a.act_assessment}
         questions = assessments.collect{|a| a.act_questions}.flatten.uniq
         vdx_metric = questions.select{|q| q.is_calibrated}.size
      end 
      
      if var.abbrev == "CAU"
         class_assesses = c.act_assessment_classrooms.select{|ca| ca.created_at >=@start_date && ca.created_at<= @end_date}
         vdx_metric = class_assesses.select{|a| a.act_assessment.is_calibrated}.size
      end 
      
     @c_metrics[idx] << vdx_metric
    end      
  end
  end    
    
  end

  def classroom_dashboard

  initialize_parameters
  
  end


  def edit_options

  initialize_parameters
  
   @options = TchrOption.find_by_user_id(@current_user.id) rescue nil
   new_start_valid = true
   new_end_valid = true
   if @options
     start_date = DateTime.parse(params[:start_date] || Time.now.strftime("%Y-%m-%d")).strftime("%Y-%m-%d") rescue new_start_valid = false
     end_date = DateTime.parse(params[:end_date] || Time.now.tomorrow.strftime("%Y-%m-%d")).strftime("%Y-%m-%d") rescue new_end_valid = false
     if new_start_valid
       @options.start_date = start_date
     end
     if new_end_valid
       @options.end_date = end_date
     end
      if request.post?
       if @options.update_attributes params[:tchr_option]
         flash[:notice] = "Options Updated Successfully"       
        else
         flash[:error] = @options.errors.full_messages.to_sentence 
       end
             
        params[:tmet_check] ||= []
        params[:tmet_check].each do |m|
          metric = TchrMetric.find_by_id(m)rescue nil
          if @options.tchr_metrics.include?(metric) 
          then
          @options.tchr_metrics.delete metric
          else
          @options.tchr_metrics<<metric
          end
          until @options.tchr_metrics.for_teacher.size < 11
           rem_metric = @options.tchr_metrics.for_teacher.last
           @options.tchr_metrics.delete rem_metric
           end
        end
                     
        params[:cmet_check] ||= []
        params[:cmet_check].each do |m|
          metric = TchrMetric.find_by_id(m)rescue nil
          if @options.tchr_metrics.include?(metric) 
          then
          @options.tchr_metrics.delete metric
          else
          @options.tchr_metrics<<metric
          end
          until @options.tchr_metrics.for_classroom.size < 9
           rem_metric = @options.tchr_metrics.for_classroom.last
           @options.tchr_metrics.delete rem_metric
          end
        end
      end
   end
   redirect_to :action => 'index', :organization_id => @current_organization, :classroom_id => @classroom
  end

  private
  
  def initialize_parameters 

    @options = TchrOption.find_by_user_id(@current_user.id) rescue nil
    unless @options
      @options = TchrOption.new
      @options.start_date = (Time.now - 12.months).beginning_of_month
      @options.end_date = (Time.now).end_of_month
      @options.end_is_current_date = true
      @options.user_id = @current_user.id
      @options.save
    end
    @start_date = @options.start_date
    if @options.end_is_current_date
      @end_date = DateTime.parse(Time.now.strftime("%Y-%m-%d"))
    else
      @end_date = @options.end_date
    end
    @current_standard = @current_user.act_master
    @current_organization = Organization.find_by_public_id(params[:organization_id])rescue nil
    if params[:subject_id]
      @current_subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
    end
    if params[:classroom_id]
      @classroom = params[:classroom_id] ? Classroom.find_by_public_id(params[:classroom_id]) : @current_organization.classrooms.active.first rescue nil
    end
    if params[:topic_id]
      @topic = Topic.find_by_public_id(params[:topic_id])rescue nil
    end
    if params[:teacher_id]
      @teacher = User.find_by_public_id(params[:teacher_id])rescue nil
    end
  end
end
