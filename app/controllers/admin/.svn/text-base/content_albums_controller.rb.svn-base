class Admin::ContentAlbumsController < Admin::ApplicationController
  layout false
  
  def index
    load_content_albums
  end
  
  def new
    @content_album = ContentAlbum.new
  end
  
  def create
    @content_album = ContentAlbum.new(params[:content_album])    
    if request.post? 
      @content_album.organization = @current_organization
      if  @current_organization.content_albums << @content_album
        render_index_as_rjs
      else 
        responds_to_parent do  
          render :update do |page|
            page.replace_html 'content_panel', :file => 'admin/content_albums/new'
          end
        end
      end
    end
  end
  
  def edit
    @content_album = ContentAlbum.find_by_public_id(params[:content_album_id])
  end
  
  def update
    @content_album = ContentAlbum.find_by_public_id(params[:content_album_id])
    if @content_album.update_attributes(params[:content_album])
      render_index_as_rjs
    else
      responds_to_parent do  
        render :update do |page|
          page.replace_html 'content_panel', :file => 'admin/content_albums/edit', :object => @content_album
        end
      end      
    end    
  end
  
  def destroy
    @content_album = ContentAlbum.find_by_public_id(params[:content_album_id])
    @content_album.destroy
    load_content_albums
    render :action => :index
  end
  
  def preview_image
    file_path = Import.image_save(params[:image_value] , ContentAlbum::IMAGE_SIZE) 
    responds_to_parent do 
      render :update do |page|
        if file_path.blank?
          page.alert("Error file type")
        else
          page.replace_html "cover_image_div" , "<img src = '#{file_path}' /><input type='hidden' name='content_album[cover]' id='content_album_cover' value='#{file_path}'>"
        end
      end
    end
  end
  
  private

  def load_content_albums
    @content_albums = @current_organization.content_albums  
  end
  
  def render_index_as_rjs
    load_content_albums
    responds_to_parent do  
      render :update do |page|
        page.replace_html 'content_panel', :file => 'admin/content_albums/index', :object => @content_albums
      end
    end          
  end
end
