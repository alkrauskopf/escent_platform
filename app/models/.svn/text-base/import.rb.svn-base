class Import
  IMAGE_SIZE = '140x140'
  
  def self.image_save(files , image_size = IMAGE_SIZE)
    return nil if files.blank?
    str_path = uuid_path
    file_path = "#{RAILS_ROOT}/public" + str_path + "/"
    mkdir_filepath(file_path)
    file_type = File.extname(files.original_filename).downcase
    return nil if !['.jpg','.png','.jpeg','.gif','.bmp','.png'].include?(file_type)  
    file_name = UUIDTools::UUID.random_create.to_s + file_type
    save_path = file_path + file_name
    File.open(save_path , "wb") do |f|
      f.write(files.read)
    end
    
    original_image = Magick::Image.read(save_path).first
    img_size = set_size(original_image , image_size.split("x")[0].to_i)
    width,height = img_size[0] , img_size[1]
    resize_image = original_image.resize(width,height)
    resize_image_path = file_path + "resize" + file_name
    resize_image.write(resize_image_path)
    
    return str_path + "/" + "resize" + file_name
  end
  
  def self.uuid_path
    uuid = UUIDTools::UUID.random_create.to_s
    "/images/our_causes/#{uuid[0].chr}/#{uuid[1].chr}/#{uuid}"
  end
  
  def self.mkdir_filepath(path)
    FileUtils.mkdir_p(path) if !File::exist?(path)
  end
  
  def self.set_size(original_image , min_size = 120)
     height = original_image.rows
     width = original_image.columns
     size = [width , height]
#     size = width >= height ? [min_size , (min_size*height.to_f)/width.to_f] :  [ (min_size*width.to_f)/height.to_f , min_size] 
     return size
  end
  
end