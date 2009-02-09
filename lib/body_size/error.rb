# = BodySize Module
#
# Purpose: Keep BodySize specifc classes in their own namespace to avoid problems.
#
module BodySize
  
    #
    # Purpose:  All exception classes for the BodySize module go here.
    #
    
    
    # == BodySize Error
    #
    # Purpose: A generic Error class
    #
    class Error < RuntimeError;  end


    # == BodySize Import Error
    #
    # Purpose: For raising errors that occur during import
    #
    class ImportError < Error
      
        #
        # Purpose: The errors attribute contains details about all of the errors that occur during the import process
        #
        attr :errors
        
        #
        # Purpose: Create a new Import Error object
        #
        # Input: errors (array) [optional] - A list of errors that have occurred.
        # Output: The @errors instance variable stores all errors
        #
        def initialize(errors=[])
            @errors = errors
        end
    end



    # == BodySize Export Error
    #
    # Purpose: For raising errors that occur during export
    #
    class ExportError < Error; end


    # == BodySize Option Error
    #
    # Purpose: For raising errors when an import or export object is created with invalid option types for required options
    #
    class OptionError < Error; end
    
    
    
    # == BodySize Missing Option Error
    #
    # Purpose: For raising errors when an import or export object is created when missing required options
    #
    class MissingOptionError < OptionError; end
end
