# = BodySize Module
#
# Purpose: Keep BodySize specifc classes in their own namespace to avoid problems.
#
module BodySize
  
  
    # == BodySize Export
    #
    # Purpose: Contain the necessary classes for exporting Bodysize objects
    #
    module Export
      
        # === BodySize Export CSV
        #
        # Purpose: Provide functionality to export bodysize records to CSV format
        #
        class CSV < BodySize::Base
          
          
            #
            # Purpose: Allow read only access to instance variables.
            # * header (array of strings) - A list of column headers
            # * csv_string (string) - The bodysize data in CSV format.
            #
            attr_reader :header, :csv_string



            #
            # Purpose: Create a new BodySize Export CSV objct
            #
            # Input:
            # * data (array of bodysizes) - The records to export
            # * options (hash) [optional] - Additional options
            #
            # Output: 
            # * The @header instance variable is initalized to an empty array
            # * The @csv_string instance variable is initialized to an empty string
            #
            # Side Effects: requires fastercsv
            #
            def initialize(data, options = Hash.new())
                super(data, options)
                require 'fastercsv'
                @header = []
                @csv_string = ''
            end      


            #
            # Purpose: Begin the export process
            #
            # Input: None
            #
            # Output: Raises an ExportError if an error occurs
            #
            def execute()
                begin
                    _execute()
                rescue BodySize::ExportError 
                    raise
                end
            end

            
            private


            #
            # Purpose: Actually export the data to CSV format
            # Input: None
            # Output: None
            #
            def _execute()
                create_header()
                create_export_string()
            end

            
            #
            # Purpose: The base class has a validate_options method which requires options that are not 
            # required for CSV export. This method over-rides the parent method and avoids the unnecessary
            # validation
            #
            # Input: None
            # 
            # Output: None
            #
            def validate_options()
              # Override the base class method because export does not require any options
            end


            #
            # Purpose: Create an array of strings which represent the attribute names
            # for the Bodysize model.
            # Strip off and trailing "_id" on an attribute so that the 
            # association can be used instead.  For example, prefer "period"
            # over "period_id".
            #
            # Input: None (Header fields are based on the fields_to_include attribute of the @options instance variable)
            # Output: The @header instance variable is set with a list of header fields
            #
            def create_header()
                header = []

                if @options[:fields_to_include]
                    @options[:fields_to_include].each() do |field|
                        header << field.to_s
                    end
                else
                    Bodysize.new().attribute_names().each() do |attrib|
                        header << attrib = attrib.gsub(/^(.+)_id$/, '\1')
                    end
                end

                @header = header
            end


            #
            # Purpose: Create the csv export string based on the passed in Bodysize 
            # active record collection.
            # Set the @csv_string attribute with the computed csv value.
            #
            # Input: None
            # Output: The @csv_string instance variable is given the correct CSV data
            #
            # Note: this method does not check to see if squirly attributes are
            # being passed in, such as .destroy().  Beware.
            def create_export_string()
                @csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
                    # Set the header row.
                    csv << @header
                    @data.each() do |rec|
                        # Create an array of attribute values and feed to the csv
                        # generator.
                        begin
                            csv << @header.collect {|attrib| rec.send(attrib.to_sym)}
                        rescue NoMethodError => e
                            raise BodySize::ExportError, e
                        end
                    end
                end
            end
        end
    

        #
        # Purpose: Allow Bodysize records to be exported to XML format
        #
        # This is currently unimplemented.
        #
        class XML < BodySize::Base
            
            
            #
            # Unimplemented
            #
            def initialize(data, options = Hash.new())
                super(data, options)
            end      
        end
    end
end
