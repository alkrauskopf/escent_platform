module UtilityScopes
  module Limited
    
    def self.included(within)
      
      within.class_eval do
      
        # Provide default limit scope (can be overridden
        # if default_limit is called)
        scope :limited, lambda { |*num|
          { :limit => num.flatten.first || (defined?(per_page) ? per_page : 10) }
        }
        
        extend ClassMethods
      end
    end
    
    module ClassMethods
      
      # Set the default limit to use for the limit scope
      def default_limit(default)
        scope :limited, lambda { |*num| { :limit => num.flatten.first || default } }
      end      
    end
  end
end