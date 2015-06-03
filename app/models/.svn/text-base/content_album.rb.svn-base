class ContentAlbum < ActiveRecord::Base
  include PublicPersona
  belongs_to :organization
  has_and_belongs_to_many :contents
  
  validates_presence_of :name
  
  IMAGE_SIZE = "50x50"
  
  def cover_show
    cover.blank? ? name : "<img src='#{cover}' \/>"
  end
  
end
