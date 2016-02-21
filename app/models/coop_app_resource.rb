class CoopAppResource < ActiveRecord::Base

  belongs_to :organization
  belongs_to  :content
  belongs_to  :coop_app
 
  scope :featured, :conditions => ["is_featured"]
  scope :by_position, :order => 'position'
  scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}
  scope :for_app, lambda{|app| {:conditions => ["coop_app_id = ? ", app.id]}}
  scope :for_content, lambda{|res| {:conditions => ["content_id = ? ", res.id]}}

  def sequence_resources
    app = self.coop_app
    self.organization.coop_app_resources.for_app(app).by_position.each_with_index do |rsrc, idx|
       rsrc.update_attributes(:position=>idx+1)
    end
  end

 
  def reposition(new_position, insert)
    app = self.coop_app
    old_position = self.position
    self.update_attributes(:position=>new_position)
    self.organization.coop_app_resources.for_app(app).by_position.each do |rsrc|
      unless rsrc == self
        if (rsrc.position > old_position) && (rsrc.position <= new_position) && !insert
          rsrc.update_attributes(:position=>rsrc.position-1)       
          elsif (rsrc.position < old_position) && (rsrc.position >= new_position) && !insert  
            rsrc.update_attributes(:position=>rsrc.position+1)
            elsif (rsrc.position >= new_position) && insert  
              rsrc.update_attributes(:position=>rsrc.position+1)
        end
      end
    end
  self.sequence_resources
  end

end
