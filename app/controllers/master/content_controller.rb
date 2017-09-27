class Master::ContentController < Master::ApplicationController

  before_filter :find_content, :only => [:edit, :show, :delete]
  require "rexml/document"
  def index
    @contents = Content.all
  end

  def trash
    @contents = Content.trash
  end
  
  def empty_trash
    Content.destroy_all(:is_delete => true)
    redirect_to :back
  end
  
  def new
    @content = Content.new
    if request.post?
      @content = Content.new(params[:content])
      @content.except_terms_or_service_vaild = true
      if @content.save
        flash[:notice] = "Successfully created content #{@content.title}."
        redirect_to :action => :index
      else
        flash[:error] = @content.errors.full_messages.to_sentence
      end
    end
  end
  
  def edit
    if request.post?
      @content.except_terms_or_service_vaild = true
      if @content.update_attributes(params[:content])
        flash[:notice] = "Successfully updated content #{@content.title}."
        redirect_to :action => :index
      else
        flash[:error] = @content.errors.full_messages.to_sentence
      end
    end
  end
  
  def show
  end
  
  def delete
    if request.post?
      @content.destroy
      flash[:notice] = "Successfully removed content #{@content.title}."
      redirect_to :action => :index
    end
  end
  
  def import
    @contents = []
    @status = ""
    users = {}
    organizations = {}
    if request.post?
      data = params["upload"]["datafile"].read
      
      doc = REXML::Document.new data
      
      @count =0 
      
      begin
        doc.root.each_element('//Contents/item') do |element|
          #Skip first two rows
          if @count > 1
            @content = Content.new        
            @content.title = element.elements['Title'].get_text
            @content.caption = element.elements['Caption'].get_text
            @content.except_terms_or_service_vaild = true
            
            if organizations.include?(:"#{element.elements['OrganizationID'].get_text}")
              @content.organization_id = organizations[:"#{element.elements['OrganizationID'].get_text}"]
            else
              @content.organization_id = Organization.where("name like '%#{element.elements['OrganizationID'].get_text}%'").first rescue 0
              organizations[:"#{element.elements['OrganizationID'].get_text}"] = @content.organization_id
            end
            
            @content.series =  element.elements['Series'].get_text rescue ''
            @content.description =  element.elements['Description'].get_text rescue ''
            @content.source_name =   element.elements['Source_name'].get_text rescue ''
            @content.source_url =  element.elements['Source_URL'].get_text rescue ''
            @content.star_performer =  element.elements['Star_Performer'].get_text rescue ''
            @content.creator_name =  element.elements['Creator'].get_text rescue ''
            
            if element.elements['Publish_Start_Date'].get_text == "Current Date"
              @content.publish_start_date = Time.now
            else
              @content.publish_start_date =  element.elements['Publish_Start_Date'].get_text rescue Time.now              
            end
            
            if element.elements['Publish_End_Date'].get_text == "Never"
              @content.publish_end_date = nil
            else
              @content.publish_end_date =  element.elements['Publish_End_Date'].get_text rescue nil              
            end
            
            @content.content_status_id =  element.elements['Status'].get_text == "Available" ? 1:2 rescue 1
            
            #Ignore for now
            #@content.affiliate priority tags = @item[7]
            #@content.user tags = @item[8]
            #@content.duration = @item[9]
            #@content.affiliate restrctions = @item[17]
            #@content.application id = @item[18]
            #No member id only user id
            #@content.member id = @item[20]
            
            if users.include?(:"#{element.elements['Member_ID'].get_text}")
              @content.user_id = users[:"#{element.elements['Member_ID'].get_text}"]
            else
              @content.user_id = User.find_by_email_address("#{element.elements['Member_ID'].get_text}") rescue 0         
              users[:"#{element.elements['Member_ID'].get_text}"] = @content.user_id
            end
            
            #From RL URL
            @content.source_file_file_name = element.elements['RL_URL'].get_text
            
            #From source_file_file_name
            #        @content.content_object_type_id = FLV?
            
            #Add object to content array
            @contents << @content
            #          end
          end
          @count += 1
        end 
      rescue => ex
        @status = "ERROR: " + ex.message + "<br/>"
        #@status = "ELEMENT: " + element.xpath 
      end
      
    end
  end
  
  def import2
    #    debugger
    @contents = []
    if request.post?
      # begin
      #Process File
      
      
      @status = ""
      @data = params["upload"]["datafile"].read
      @ary = @data.split(/\r/)
      @ary.each do |x|
        @item = x.split(",")
        
        @content = Content.new        
        
        @content.title = @item[1]
        @content.caption  = @item[2]
        unless @item[3].nil?
          #          @content.organization_id = Organization.find(:first, :conditions => "name = '#{@item[3]}'") #DO LOOKUP
        else
          @content.organization_id = "0"
        end
        
        @content.organization_id =      
        
        @content.series = @item[5]
        @content.description = @item[6]
        @content.source_name = @item[10]
        @content.source_url = @item[11]
        @content.star_performer = @item[13] 
        @content.creator_name = @item[12]
        @content.publish_start_date = @item[14]
        @content.publish_end_date= @item[15]
        @content.content_status_id = @item[16] = "Available" ? 1:2
        
        #Ignore for now
        #@content.affiliate priority tags = @item[7]
        #@content.user tags = @item[8]
        #@content.duration = @item[9]
        #@content.affiliate restrctions = @item[17]
        #@content.application id = @item[18]
        #No member id only user id
        #@content.member id = @item[20]
        unless @item[19].nil?
          @content.user_id = User.find_by_email_address(@item[19])          
        end
        
        #From RL URL
        @content.source_file_file_name = @item[4]
        
        #From source_file_file_name
        #        @content.content_object_type_id = FLV?
        
        #Add object to content array
        @contents << @content
      end
      
      #If file was processed without error then commit to database
      #Do nothing
      # rescue => ex
      # @status = "ERROR:<br/>" + ex.message + "<br/>" 
      
      
      #If exception then remove anything we committed
      #@contents.each {|r| r.remove }
      #end
    end
  end
  
  protected
  
  def find_content
    @content = Content.find(params[:id])
  end
end
