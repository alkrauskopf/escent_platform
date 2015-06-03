# Main module for authentication.  
# Include this in ApplicationController to activate AuthorizationRequirement
#
# See AuthorizationSecurityClassMethods for some methods it provides.
module AuthorizationRequirement
  def self.included(klass)
    klass.send :class_inheritable_array, :authorization_requirements
    klass.send :include, AuthorizationSecurityInstanceMethods
    klass.send :extend, AuthorizationSecurityClassMethods
    klass.send :helper_method, :url_options_authenticate? 
  end
  
  module AuthorizationSecurityClassMethods
    
    def reset_authorization_requirements!
      self.authorization_requirements=nil
    end
    
    # Add this to the top of your controller to require a role in order to access it.
    # Example Usage:
    # 
    #    require_authorization "superuser"
    #    require_authorization "friend"
    #    require_authorization "content_manager"    
    #    require_authorization "superuser"
    #    require_authorization "manage_topic"
    #    require_authorization "upload_content delete_content", :only => :destroy # don't allow contractors to destroy
    #    require_authorization "manage_web_site manage_organization_relationship", :only => :update, :unless => "@current_user.authorized_for?(params[:id]) "
    #
    # Valid options
    #
    #  * :only - Only require the authorization for the given actions
    #  * :except - Require the authorization for everything but 
    #  * :if - a Proc or a string to evaluate.  If it evaluates to true, the authorization is required.
    #  * :unless - The inverse of :if
    #    
    def require_authorization(authorizations, options = {})
      options.assert_valid_keys(:if, :only, :except, :unless, :include_child_scopes)
      
      # only declare that before filter once
      unless (@before_filter_declared||=false)
        @before_filter_declared=true
        before_filter :check_authorizations
      end
      
      # pre-process the authorizations
      ary = authorizations.split(/\s+/)
      authorizations = {:permissions => ary.collect{|p| p.downcase}}
      
      # convert any actions into symbols
      for key in [:only, :except]
        if options.has_key?(key)
          options[key] = [options[key]] unless Array === options[key]
          options[key] = options[key].collect{|v| v.to_sym}
        end 
      end
      
      self.authorization_requirements||=[]
      self.authorization_requirements << {:authorizations => authorizations, :options => options }
    end
    
    # This is the core of AuthorizationRequirement.  Here is where it discerns if a user can access a controller or not.
    def user_authorized_for?(user, scope, params = {}, binding = self.binding)
      return true unless Array===self.authorization_requirements
      self.authorization_requirements.each{| authorization_requirement|
        authorizations = authorization_requirement[:authorizations]
        options = authorization_requirement[:options]
        # do the options match the params?
        
        # check the action
        if options.has_key?(:only)
          next unless options[:only].include?( (params[:action]||"index").to_sym )
        end
        
        if options.has_key?(:except)
          next if options[:except].include?( (params[:action]||"index").to_sym)
        end
        
        if options.has_key?(:if)
          # execute the proc.  if the procedure returns false, we don't need to authenticate these authorizations
          next unless ( String===options[:if] ? eval(options[:if], binding) : options[:if].call(params) )
        end
        
        if options.has_key?(:unless)
          # execute the proc.  if the procedure returns true, we don't need to authenticate these authorizations
          next if ( String===options[:unless] ? eval(options[:unless], binding) : options[:unless].call(params) )
        end
        
        # check to see if they have one of the required authorizations
        passed = false
        if user && scope
          passed = authorizations[:permissions].all?{|permission| AuthorizationLevel.find_by_name(permission) ? user.has_authorization_level_for?(scope, permission) : user.authorized_for?(scope, permission)}
        end
        
        return false unless passed
      }
      
      return true
    end
  end
  
  module AuthorizationSecurityInstanceMethods
    def check_authorizations
      return access_denied("Insufficient authorization.") unless self.class.user_authorized_for?(current_user, current_scope, params, binding)
      
      true
    end
    
  protected
    # receives a :controller, :action, and :params.  Finds the given controller and runs user_authorized_for? on it.
    # This can be called in your views, and is for advanced users only.  If you are using :if / :unless eval expressions, 
    #   then this may or may not work (eval strings use the current binding to execute, not the binding of the target 
    #   controller)
    def url_options_authenticate?(params = {})
      params = params.symbolize_keys
      if params[:controller]
        # find the controller class
        klass = eval("#{params[:controller]}_controller".classify)
      else
        klass = self.class
      end
      klass.user_authorized_for?(current_user, current_scope, params, binding)
    end
  end
end