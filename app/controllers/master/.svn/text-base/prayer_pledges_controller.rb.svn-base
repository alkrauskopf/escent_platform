class Master::PrayerPledgesController < Master::ApplicationController
  has_sms_fu
    
  before_filter :load_prayer_pledges
  
  def index
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @address_types }
    end
  end
  
  def clear_phone
    if request.post?
      PrayerPledge.clear_error_phone_number
    end
    redirect_to :back
  end
  
  def download_excel
    attach_file = PrayerPledge.create_excel(@prayer_pledges)
    send_file attach_file[0] , :filename => attach_file[1]
  end

  def send_sms
#    deliver_sms("2174191627","at&t", "Your requested reminder: pray for peace at noon on today!",:from =>"noreply@odysseynetworks.org")
#    deliver_sms("303-250-0436","AT&T", "Your requested reminder: pray for peace at noon on today!",:from =>"noreply@odysseynetworks.org")
#    prayer_pledges = PrayerPledge.find(:all, :conditions => ["should_inform = true and phone_number is not null and (phone_number <> '' AND phone_number NOT LIKE 'XXX-XXX-XXXX' )"])
#    fh = File.open(RAILS_ROOT + "/public/send_sms.log", "w")
#    prayer_pledges.each do |prayer|
#
#      begin
#        a = get_sms_address(prayer.phone_number, prayer.phone_provider)
#        deliver_sms(prayer.phone_number, prayer.phone_provider, "Your requested reminder: pray for peace at noon today!",:from =>"noreply@odysseynetworks.org")
#      rescue
#        a = "error: " + prayer.phone_number + " " + prayer.phone_provider
#      end
#      fh.puts a
#    end
#    fh.close
#    render :text => "successful"
  end
  
  
private
  def load_prayer_pledges
     @prayer_pledges= PrayerPledge.all
  end
end
