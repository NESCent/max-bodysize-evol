# = BodySize Module
#
# Purpose: Keep BodySize specifc classes in their own namespace to avoid problems.
#
module BodySize
  
    # == Base
    # 
    # Purpose: Servce as a base class to the BodySize import and export CSV classes
    #
    class Base
      
        #
        # Purpose: Define default options for CSV import/export
        #
        DEFAULT_OPTIONS = {:header => false,
            :header_source_path => "#{RAILS_ROOT}/doc/CSV Data/Bodysize Official CSV Column Order.csv"
        }.freeze()
      
        #
        # Allow read only access to the data attribute
        #
        attr_reader :data
        
        
        #
        # Purpose: When creating a new import or export object, setup defaults
        #
        # Input:
        # * data (string) - CSV Data
        # * options (hash) [optional] - Any additional options
        #
        # Output: None
        #
        def initialize(data, options = Hash.new())
            @options = DEFAULT_OPTIONS.merge(options)
            @data = data
            @logger = DEFAULT_LOGGER

            validate_options()
        end
    
    
        #
        # Purpose: Determine if the 'header' option was set
        #
        # Input: None
        #
        # Output: 
        # * The 'header' option if it is set
        # * nil, otherwise
        #
        def has_header?()
            @options[:header]    
        end


        private


        #
        # Purpose: Ensure that all required options are present
        #
        # Input: None
        #
        # Output: 
        # * Raises a MissingOptionError if any required options are missing
        # * Raises an OptionError if required options are present but of the wrong type
        # * Returns nothing otherwise
        #
        # Requirements:
        # * An instance of the User model must be passed in through the :user option.
        def validate_options()
            unless @options[:user]
                raise BodySize::MissingOptionError, "The option, user, is required."
            end

            unless @options[:user].is_a?(User)
                raise BodySize::OptionError, 
                    "The user option must contain a User model instance."
            end
        end
    end
end
