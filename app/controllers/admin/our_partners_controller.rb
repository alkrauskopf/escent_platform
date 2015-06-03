class Admin::OurPartnersController < Admin::ApplicationController
  def add_organization_relationship
#    debugger
    params[:scope_ids].each do |id| 
      if params[:scope] == "Organization"
        target = Organization.find_by_public_id(id)
      else
        target = ReligiousAffiliation.find(id)
      end
      @current_organization.organization_relationships.create(:target => target, 
                                                              :relationship_type => params[:relationship_type])
    end
    
    organization_relationships = @current_organization.organization_relationships.find_all_by_relationship_type(params[:relationship_type], :order => "relationship_type")
    
    @organization_relationships = organization_relationships
    
    if request.xhr? && params[:scope] == "Organization"
      render :file => "/admin/our_partners/add_organization_relationship.js" and return
    end
    render :partial => "organization_relationships_table", :locals => {:relationship_type => params[:relationship_type], :collection => organization_relationships}
  end
  
  def update_relationship_inclusive
    relationship = OrganizationRelationship.find(params[:relationship_id])
    relationship.inclusive = params[:include]
    relationship.save
    
    render  :text => nil   
  end
  
  def remove_organization_relationship
    @current_organization.remove_organization_relationship(params[:id])
    organization_relationships = @current_organization.organization_relationships.find_all_by_relationship_type(params[:relationship_type], :order => "relationship_type")
    render  :partial => "organization_relationships_table", :locals => {:relationship_type => params[:relationship_type], :collection => organization_relationships}
  end
  
  def organization_search
    if request.xhr?
      @organizations = Organization.paginate :per_page => 10, :page => params[:page]
      render :partial => "/admin/our_partners/organization_search_results"   
    end  
  end  
end
