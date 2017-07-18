class ContentObjectTypeGroup < ActiveRecord::Base

  scope :images, :conditions => { :name => "IMAGE" }


  def self.active
    where('is_active').order('name ASC')
  end

  def self.all_by_name
    order('name ASC')
  end
  def active?
    self.is_active
  end

  def needs_attachment?
    self.content_format == 'Attachment'
  end

  def needs_string?
    self.content_format == 'String'
  end

  def needs_text_block?
    self.content_format == 'Text Block'
  end

end
