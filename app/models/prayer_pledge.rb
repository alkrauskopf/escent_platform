class PrayerPledge < ActiveRecord::Base
  include PublicPersona
    
  attr_accessor :age_verified, :allow_me_to_particapte, :text_me, :password, :teams_of_service
  
  belongs_to :organization
  belongs_to :user  
    
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :email_address
  validates_presence_of :country
  validates_presence_of :phone_number, :on => :update, :if => Proc.new { |prayer_pledge| prayer_pledge.text_me == "1" }  
  validates_presence_of :phone_provider, :on => :update, :if => Proc.new { |prayer_pledge| prayer_pledge.text_me == "1" }  
  validates_presence_of :password, :on => :update, :if => Proc.new { |prayer_pledge| prayer_pledge.allow_me_to_particapte == "1" }

  validates_length_of :password, :minimum => 7, :message => "Minimum 7 characters", :if => Proc.new { |prayer_pledge| prayer_pledge.allow_me_to_particapte == "1" }

  validates_uniqueness_of :email_address
  
  validates_acceptance_of :age_verified, :on => :create, :allow_nil => false
  validates_acceptance_of :teams_of_service, :on => :update, :allow_nil => false, :message => 'Must Be Accepted',
                          :if => Proc.new { |prayer_pledge| prayer_pledge.allow_me_to_particapte == "1" }  
  
  validates_format_of :first_name, :with => /^[\w\s'-`]+$/, :message => 'not valid', 
                      :allow_nil => false
  validates_format_of :last_name, :with => /^[\w\s'-`]+$/, :message => 'not valid', 
                      :allow_nil => false
  validates_format_of :email_address, :with => /^[\w._%+-]+@[\w.-]+\.[\w]{2,6}$/, :message => 'not valid', 
                      :allow_nil => false

  validates_format_of :phone_number, :with => /^[2-9]\d{2}-\d{3}-\d{4}$/, :message => 'should be XXX-XXX-XXXX', 
                      :on => :update, :if => Proc.new { |prayer_pledge| prayer_pledge.text_me == "1" }

                      
  validates_confirmation_of :email_address
  validates_confirmation_of :password, :on => :update, :if => Proc.new { |prayer_pledge| prayer_pledge.allow_me_to_particapte == "1" }      
  
  PHONE_PROVIDER = ["AT&T", "Verizon", "T-Mobile", "Sprint"]
  ATTRS = ["first_name", "last_name", "email_address", "country"]
  
  def after_initialize
    self.country = "US" if self.country.nil?
  end
  
  def self.update_or_create_user(prayer_pledge, params)
    user = User.find_by_email_address(params[:email_address]) || User.new
    user.first_name = prayer_pledge.first_name
    user.last_name = prayer_pledge.last_name
    user.email_address = prayer_pledge.email_address
    user.country = prayer_pledge.country
    user.password = params[:password]
    user.age_verified = true
    user.read_tos = true
    user.save!
    organization = prayer_pledge.organization
    user.add_as_friend_to(organization)
    prayer_pledge.user_id = user.id
    prayer_pledge.save!
  end
  
  def email_reminder
    send_reminder_day_before ? "Yse" : "No"
  end
  
  def self.create_excel(objs)
    file_name = "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
    file_path = "#{RAILS_ROOT}/public/master/"
    FileUtils.mkdir_p(file_path) if !File::exist?(file_path)
    file_dir = file_path + file_name
    workbook = Spreadsheet::Excel.new(file_dir)
    worksheet = workbook.add_worksheet("Report on Pledges")
    worksheet.write(0 , 0 , ["First Name" , "Last Name" , "Email Address" , "Email Reminder" , "Phone" , "Created"])
    objs.each_with_index do |obj , key|
       worksheet.write(key + 1, 0, [obj.first_name, obj.last_name , obj.email_address ,obj.email_reminder , obj.phone_number , obj.created_at.strftime('%Y-%m-%d %H:%M')])
    end
    workbook.close
    [file_dir , file_name]
  end
  
  def self.clear_error_phone_number
    prayer_pledges = PrayerPledge.find(:all, :conditions => ["phone_number = ?", "XXX-XXX-XXXX"])
    prayer_pledges.each {|p| p.update_attribute("phone_number", "")}
  end
  
  def self.send_one_reminder(prayer_id)
    prayer = PrayerPledge.find(prayer_id)
    fh = File.open(RAILS_ROOT + "/public/email_reminder.log", "w")
    if prayer.i18n_locale == 'es'
      Notifier.deliver_email_reminder_es prayer.email_address, prayer
    else
      Notifier.deliver_email_reminder prayer.email_address, prayer        
    end
    fh.puts prayer.email_address 
    fh.close
  end
  
  def self.send_email_reminder
    prayer_pledges = self.find(:all, :conditions => ["should_inform = true and send_reminder_day_before = true"])    
    fh = File.open(RAILS_ROOT + "/public/email_reminder.log", "w")
    prayer_pledges.each do |prayer|
      if prayer.i18n_locale == 'es'
        Notifier.deliver_email_reminder_es prayer.email_address, prayer
      else
        Notifier.deliver_email_reminder prayer.email_address, prayer        
      end
      fh.puts prayer.email_address 
    end
    fh.close
  end
end
