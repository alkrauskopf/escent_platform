class Admin::ReportedAbusesController < Admin::ApplicationController
  def index
    @reported_abuses = @current_organization.reported_abuses
    render :layout => false
  end
end
