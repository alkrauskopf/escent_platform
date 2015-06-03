class Master::SelectsController < Master::ApplicationController
  include ImportExcel
  
  def index
    error_validate(params[:select_from]) do 
#      @results = ActiveRecord::Base.connection.execute(params[:select_from])
      @results = ActiveRecord::Base.connection.select_all(params[:select_from])
    end  
  end
  
  def result_download
    error_validate(params[:select]) do
      attach_file = ImportExcel.get_excel(params[:select])
      send_file attach_file[0] , :filename => attach_file[1] if attach_file
    end
  end

private
  def error_validate(select_from)
    begin 
      if request.post? && select_from
        if select_from.strip[0,6].downcase == "select"
          yield
        else
          flash[:error] = "Please entry  a query"
        end
      end
    rescue 
      flash[:error] = "Query error , Please check ."
    end
  end
end
