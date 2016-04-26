class MessagesController < ApplicationController
  before_filter :current_organization
  before_filter :current_user

  def create
    message = Message.new(params[:message])
    if message.save
      from_user = @current_user
      to_user = message.user
      options = {:user => to_user, :subject => "Escent", :html_body => message.content}
      UserMailer.contact(from_user.preferred_email, options).deliver
    end
  end

  def index
    @messages = @current_user.messages
    render :layout => 'site'
  end

  def delete_message
     remove_message = Message.find_by_id(params[:message_id])
     unless remove_message.nil?
       remove_message.destroy
   end
   redirect_to :action => :index
  end

  def classroom_message
    unless params[:message] == ""
      classrm = Classroom.find_by_id(params[:classroom_id])
      from_user = @current_user
     
      if params[:to] == "students" then
  
  #  Leader To Students
      subj_line = classrm.course_name + " Broadcast"
      recipients = classrm.students_of_teacher(from_user)
      email_recipients = []
      sms_recipients = []
      recipients.each do |usr|
       unless usr == from_user  
        if usr.Phone_for_Texting.blank? || usr.Provider_of_Texting_Service == "No Texting Wanted"
         then email_recipients << usr
         else sms_recipients << usr 
        end
       end     
      end
      email_recipients.each do|to_user|
      message = Message.new(params[:message])
      message.user = to_user
        if message.save
         options = {:user => to_user, :subject => subj_line, :html_body => message.content}
         UserMailer.contact(from_user.preferred_email, options).deliver
        end
      end  
      
      unless sms_recipients.empty?
          from_line = @current_user.last_name + "@" + classrm.course_name.gsub(/[ ]/,'-')
          fh = File.open(Rails.root + "/public/send_sms.log", "w")
          sms_recipients.each do|to_user|
          message = Message.new(params[:message])
          message.user = to_user
          if message.save         
            begin
              a = get_sms_address(to_user.Phone_for_Texting, to_user.Provider_of_Texting_Service)
              deliver_sms(to_user.Phone_for_Texting, to_user.Provider_of_Texting_Service, message.content,:from => from_line)
             rescue
              a = "error: " + to_user.Phone_for_Texting + " " + to_user.Provider_of_Texting_Service
             end
             fh.puts a
            end
          end
          fh.close
       end   
    elsif params[:to] == "teachers" then
      
   # Participant to Leader
      subj_line = classrm.course_name + " Message"
      recipients = classrm.teachers_for_student(from_user)
      recipients.each do|to_user|
      unless to_user == from_user
       message = Message.new(params[:message])
       message.user = to_user
        if message.save
         options = {:user => to_user, :subject => subj_line, :html_body => message.content}
         UserMailer.contact(from_user.preferred_email, options).deliver
        end
       end
       end   
    
      end
    end
  end

end
