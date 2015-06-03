class ContentObjectType < ActiveRecord::Base
  belongs_to :content_object_type_group
  
  def self.generate_name_helpers
    self.all.each do |content_object_type|
      (class << self; self; end).class_eval do
        define_method(content_object_type.content_object_type.downcase) do
          self.find content_object_type.id
        end
      end
      define_method("#{content_object_type.content_object_type.downcase}?") do
        self == content_object_type
      end
    end
  end
  generate_name_helpers
end
