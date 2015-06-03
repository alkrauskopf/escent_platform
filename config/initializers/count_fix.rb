class ActiveRecord::Base
  protected
    def self.construct_count_options_from_args(*args)
      name_and_options = super
      name_and_options[0] = '*' if name_and_options[0].is_a?(String) && name_and_options[0] =~ /\.\*$/
      name_and_options
    end
end