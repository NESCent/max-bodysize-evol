# = BodySize Module
#
# Purpose: Keep BodySize specifc classes in their own namespace to avoid problems.
#
module BodySize
  
  
    # == BodySize Import
    #
    # Purpose: Contain the necessary classes for importing Bodysize objects
    #
    module Import
      
      
        # === BodySize Import CSV
        #
        # Purpose: Provide functionality to import bodysize records from CSV format
        #
        class CSV < BodySize::Base
          
          
            #
            # Purpose: Provide read only access to instance variables
            # * row_hashes (array) - An array of rows. Each is a hash with key value pairs for the attributes of a bodysize record
            # * insert_count (int) - A count of the number of records that were inserted.
            attr_reader :row_hashes, :insert_count

            #
            # Purpose: Create a new CSV Import object
            #
            # Input: 
            # * data (string) - The CSV data to import
            # * options (hash) - Additional options
            # 
            # Most of the options are well, optional. There is however one required option:
            # * user (User) - A user object (or subclass) must be given. The user that is given
            # will be set as the creator of all of the imported bodysize objects.
            #
            # Output: 
            # * requires fastercsv
            # * the @header_row instance variable is set
            # * @row_hashes, and @insert_count are initialized
            # 
            def initialize(data, options = Hash.new())
                super(data, options)
                require 'fastercsv'
                @header_row = retrieve_header_row()
                @row_hashes = []
                @insert_count = 0
            end
      
      
            #
            # Purpose: Begin the CSV import process
            #
            # Input: None
            # Output: Raises an ImportError if any errors occur
            #
            def execute
              begin
                _execute()
              rescue BodySize::ImportError 
                raise
              end
            end
      

            private


            #
            # Purpose: Internal method to begin the CSV import process
            #
            # Input: None
            # Output: None
            #
            def _execute
                build_row_hashes()
                create_records()
            end


            #
            # Purpose: Get the header row from the file defined by the 'header_source_path' option
            #
            # Input: None. Uses the header_source_path option as location of the file with the header row information.
            # Output: An array of fields that are the columns of the CSV file
            #
            def retrieve_header_row()
                # Retrieve the header row to use.
                header_row = []
                FasterCSV.foreach(@options[:header_source_path]) do |row|
                    # Only one header row is permitted or makes sense.
                    header_row = row
                    break
                end
        
                return header_row
            end


            #
            # Purpose: Parse the CSV data.  Create a hash for the row with the header values
            # as the hash keys and the row values as the hash values.  Insert each
            # row hash into an array.
            #
            # Input: None (Uses @data, and @header_row)
            # Output: Sets @row_hashes as an array of hashes, where each hash cooresponds to a row from the CSV file
            #
            def build_row_hashes()
                FasterCSV.parse(@data, :headers => self.has_header?(), :encoding => 'U') do |row|
                    collection = @header_row.zip(row)
                    @row_hashes << collection.inject({}) do |hash, value|
                        hash[value.first] = value.last
                        hash
                    end
                end
            end



            # 
            # Purpose: Create bodysize records based on the CSV data that was retrieved
            #
            # Input: None (Uses @row_hashes)
            #
            # Output: 
            # * Raises an ImportError if any error occur. In that case, no records are created, and ImportError.errors will contain all errors.
            # * If no errors occur, @insert_count is set to the number of records that were created
            #
            def create_records()
                errors = []
                Bodysize.transaction do
                    insert_count = 0
                    @row_hashes.each_with_index do |row, index|
                        if has_header?() #TODO verify that this works
                            row_num = index + 2
                        else
                            row_num = index + 1
                        end

                        # TODO the row hash key may not exist, e.g. "Kingdom"
                        bodysize = Bodysize.new()
                        bodysize.creator = @options[:user]

                        lookups = {
                            :kingdom= => lambda() {Kingdom.find(:first, 
                                :conditions =>["LOWER(name) = ?", row['Kingdom'].downcase()])},
                            :phylum= => lambda() {Phylum.find(:first,
                                :conditions => ["LOWER(name) = ?", row['Phylum'].downcase()])},
                            :motility= => lambda() {Motility.find(:first,
                                :conditions => ["LOWER(name) = ?", row['Motility'].downcase()])},
                            :environment= => lambda() {Environment.find(:first,
                                :conditions => ["LOWER(name) = ?", row['Environment'].downcase()])},
                            :feeding= => lambda() {Feeding.find(:first,
                                :conditions => ["LOWER(name) = ?", row['Feeding Group'].downcase()])},
                            :period= => lambda() {Period.find(:first,
                                :conditions => ["LOWER(name) = ?", row['Period'].downcase()])},
                            :formula= => lambda() {Formula.find(:first,
                                :conditions => ["LOWER(name) = ?", row['Formula used for biovolume'].downcase()])},
                        }

                        # The key is a symbol representing the bodysize model method.
                        # The value is a Proc used to lookup the value in a table.
                        lookups.each() do |key, value|
                            # The actual attribute is ':somthing=' so I want to change it to a string
                            # for display purposes and chop the '=' off.
                            attr_name = key.to_s.chop()

                            error_msg = "Cannot find corresponding record for #{attr_name} in row: #{row_num}."
                            
                            # Calling downcase() on a nil object results in an 
                            # exception but the effect is the same as if it 
                            # didn't exist in the table.  A nil could occur if
                            # there was no record returned or if the key, e.g., 
                            # 'Kingdom', was not in the hash.
                            #
                            # val will be nil if the lookup is not found
                            begin
                                val = value.call()
                            rescue NoMethodError
                                errors << error_msg
                                next
                            end

                            if val
                                # This calls the bodysize method and sets it to val.
                                bodysize.send(key, val)
                            else
                                errors << error_msg
                            end
                        end

                        attr_mapping = {
                            :class_classification= => 'Class',
                            :order_classification= => 'Order',
                            :family= => 'Family',
                            :genus= => 'Genus',
                            :species= => 'Species',
                            :epoch= => 'Epoch',
                            :expert_contacted= => 'Expert contacted',
                            :literature_citation= => 'Literature citation',
                            :other_data_source= => \
                                'Other source of data (museum specimen, personal obs., etc.)',
                            :confidence_comment= => \
                                'Expert\'s comments on confidence',
                            :compiler= => 'Compiler',
                            :first_description_literature_source= => \
                                'Literature source for first description of the species',
                            :compiler= => 'Compiler',
                            :length= => 'Length (mm)',
                            :width= => 'Width (mm)',
                            :height= => 'Height (mm)',
                            :how_estimation_was_achieved= => \
                                'how estimation was achieved',
                            :mass= => 'Mass (kg)',
                            :biovolume= => 'Biovolume (mm3)',
                            :log10_biovolume= => 'Log10 Biovolume',
                            :notes= => 'General Notes',
                        }

    
                        # Assign the attributes their CSV values.
                        attr_mapping.each() do |key, value|
                            # Check that the key exists in the row.  If it
                            # doesn't then log an error.
                            unless row.has_key?(value)
                                errors << "No such column header: #{value}"
                                next
                            end
    
                            bodysize.send(key, row[value])
                        end
    
                        unless bodysize.save()
                            bodysize.errors.each_full() {|msg| errors << "#{msg} in row: #{row_num}."}
                        else
                            insert_count += 1
                        end
                    end

                    if errors.empty?()
                        @insert_count += insert_count
                    else
                        @insert_count = 0
                        raise BodySize::ImportError.new(errors), 'import error'
                    end
                end
            end
        end
    
    
        
        #
        # Purpose: Allow Bodysize records to be imported from XML format
        #
        # This is currently unimplemented.
        #
        class XML < BodySize::Base
          
            #
            # This is currently unimplemented.
            #
            def initialize(data, options = Hash.new())
                super(data, options)
            end      
        end
    end
end
