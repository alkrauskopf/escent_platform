class PageSection < ActiveRecord::Base
  belongs_to :organization
  belongs_to :content
  belongs_to :author, :class_name => "User"
  
  validates_presence_of :organization_id
  validates_presence_of :page
  
  def unite_body(value)
    if value[:image_path].present?
      "<p><img src= '#{value[:image_path]}' /></p><p>#{value[:value]}</p>"
    else
      "<p>#{self.class.image_value(body)}</p><p>#{value[:value]}<\/p>"
    end  
  end
  
  def self.image_value(body)
    image_value = ""
    body.gsub(/\<img[^<]*\>/) do |value|
       image_value = value
    end
    image_value
  end
  
  def self.body_value(body)
    body_value = ""
    body.gsub(/\<p\>[^<]*\<\/p\>/) do |value|
      body_value << value.to_s.gsub(/\<p\>|\<\/p\>/ , "")
    end
    body_value
  end
  
end
