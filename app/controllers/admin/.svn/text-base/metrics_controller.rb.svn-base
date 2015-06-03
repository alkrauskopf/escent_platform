class Admin::MetricsController < Admin::ApplicationController
  before_filter :set_search_date
  
  def index
    render :layout => false
  end
  
  def download_excel
    attach_file = Metric.create_excel(@current_organization , @start_date , @end_date)
    send_file attach_file[0] , :filename => attach_file[1]
  end
  
private
  def set_search_date
    @start_date = DateTime.parse(params[:start_date] || Time.now.strftime("%Y-%m-%d")).strftime("%Y-%m-%d")
    @end_date = DateTime.parse(params[:end_date] || Time.now.tomorrow.strftime("%Y-%m-%d")).strftime("%Y-%m-%d")
#    @most_count = Metric.most_count(@start_date , @end_date)
  end
end
