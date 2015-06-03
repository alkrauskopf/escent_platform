class AuthorizableAction < ActiveRecord::Base
  belongs_to :authorization_level
end
