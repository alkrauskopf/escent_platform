module UtilityScopes
  module Eager
    
    def self.included(within)
      within.class_eval do
        scope :with, lambda { |*associations| { :include => associations } }
      end
    end
  end
end