class DleResource < ActiveRecord::Base
  include PublicPersona
  
  belongs_to :organization
  belongs_to  :content

  named_scope :featured, :conditions => ["is_featured"]
  named_scope :by_position, :order => 'position'
  named_scope :for_org, lambda{|org| {:conditions => ["organization_id = ? ", org.id]}}

 
  def sequence_resources
    self.organization.dle_resources.by_position.each_with_index do |rsrc, idx|
       rsrc.update_attributes(:position=>idx+1)
    end
  end
 
  def reposition(new_position, insert)

    old_position = self.position
    self.update_attributes(:position=>new_position)
    self.organization.dle_resources.by_position.each do |rsrc|
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
