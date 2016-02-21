class Metric < ActiveRecord::Base
  set_table_name "shares"
  belongs_to :organization
  
  SHARE_TYPE = [[1,"Pledges"], 
                [2,"Pledges Email Reminders"], 
                [3 , "Pledges TextMag Reminders"] ,
                [4 , "Emails For Shareing"] ,
                [5 , "New Registrations" ], 
                [6 , "UnVerified Members" ], 
                [7 , "Verified Members" ], 
                [8 ,"Network Affliates"] #,
                ]
  TITLE_HASH = {1 => "PEACE PLEDGE" , 5 => "NETWORK"}
   scope :metric_records , lambda{|type_value , start_date , end_date|
     {:conditions => ["share_type =? and created_at > ? and created_at < ?" , type_value , start_date , end_date]} 
  }
  
  def self.sum_count(key , start_date , end_date)
    options = ["created_at > '#{start_date}' and created_at < '#{end_date}'"]
    case key
     when 4
       options[0] << " and share_type = 4"
       count(:conditions => options)
     when 5
       User.count(:conditions => options)
     when 6
       options[0] << " and verified_at is null"
       User.count(:conditions => options)
     when 7
       options[0] << " and verified_at is not null"
       User.count(:conditions => options)
     when 8
       Organization.count(:conditions => options)
     end 
  end

  #create a new metric 
  def self.new(*args)
    args.size == 1 ? super : super(:share_type => args[0] , :user_id => args[1])
  end
  
  #get database about shares and other total
  def self.create_excel(org , start_date , end_date)
    file_name = "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
    file_path = "#{RAILS_ROOT}/public/metric/"
    
    FileUtils.mkdir_p(file_path) if !File::exist?(file_path)
    file_dir = file_path + file_name
    
    #create a excel
    workbook = Spreadsheet::Excel.new(file_dir)
    worksheet = workbook.add_worksheet("#{start_date}|#{end_date}")
    
    #first row , it's head
    head = ["Title" , "Information" , "Start date"]
    (DateTime.parse(start_date)..DateTime.parse(end_date)).each_with_index{|a , key| head << "#{key + 1} Day"}
    head << "End date"
    head << "Total"
    
    #set 1 row collor
    f1 = workbook.add_format(:bg_color=>"yellow", :bold=>1, :italic=>true)
    
    worksheet.write(0 , 0 , head , f1)
    SHARE_TYPE.each_with_index do |value , key|
      metrics_search = org.metrics.metric_records(value[0] , start_date , end_date)
      arr = [TITLE_HASH[value[0]] , value[1] , "#{start_date}"]
     (DateTime.parse(start_date)..DateTime.parse(end_date)).each do |date|
       arr << Metric.sum_count(value[0], DateTime.parse(date.to_s).strftime("%Y-%m-%d") , DateTime.parse(date.to_s).tomorrow.strftime("%Y-%m-%d"))
     end
      arr << "#{end_date}"
      arr << Metric.sum_count(value[0],start_date,end_date)
      worksheet.write(key+1 , 0 , arr)
    end
    workbook.close
    [file_dir , file_name]
  end
end
