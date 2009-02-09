require File.dirname(__FILE__) + '/../test_helper'

class BaseTest < ActiveSupport::TestCase
    def setup
        @user = User.find(:first)
    end

    def test_user_option()
        # The :user option is required.
        assert_raise(BodySize::MissingOptionError) do 
            BodySize::Import::CSV.new('foo')
        end

        # The :user option must be an instance of User model.
        assert_raise(BodySize::OptionError) do
            BodySize::Import::CSV.new('foo', :user => 'not a User instance')
        end

        assert_nothing_raised(BodySize::OptionError) do
            BodySize::Import::CSV.new('foo', :user => @user)
        end
    end

    def test_header_source_path()
        # The :header_source_path is not required.
        

        # The :header_source_path must be a valid, parseable CSV file
    end
end


class ErrorTest < ActiveSupport::TestCase
    # The ImportError has an initializer and attributes that can be read.
    def test_import_exception()
        exception = BodySize::ImportError.new()

        # The errors attribute must be an array.
        assert(exception.errors.is_a?(Array), "The errors attribute must be an array.")
    end
end


class ImportTest < ActiveSupport::TestCase
    fixtures :properties, :formulas, :periods
    self.use_transactional_fixtures = false

    def setup
        fh = open("#{RAILS_ROOT}/test/data/bad_mock_data.csv", "rb")
        @bad_csv_data = fh.read()
        fh.close()

        fh = open("#{RAILS_ROOT}/test/data/good_mock_data.csv", "rb")
        @good_csv_data = fh.read()
        fh.close()

        @user = User.find(:first)

        Bodysize.delete_all()
    end

    def test_execute_bad_data()
        import = BodySize::Import::CSV.new(@bad_csv_data, :user => @user,
                   :header_source_path => "#{RAILS_ROOT}/test/data/bodysize_header.csv")
                   
        assert_raises(BodySize::ImportError) do
            # Wrapping in a begin/rescue so that e can be captured and tested
            # later.  It is set to an instance variable in order to persist
            # beyond this assertion.
            begin
                import.execute()
            rescue BodySize::ImportError => @e
                raise
            end
        end
        assert_equal(false, @e.errors.blank?())
        assert_equal(0, import.insert_count, "Database count does not match insert_count.")
        assert_equal(0, Bodysize.count(), "Incorrect database count.")
    end

    def test_execute_good_data()
        import = BodySize::Import::CSV.new(@good_csv_data, :user => @user,
                   :header_source_path => "#{RAILS_ROOT}/test/data/bodysize_header.csv")
        assert_nothing_raised(BodySize::ImportError) {import.execute()}
        assert_equal(10, import.insert_count, "Database count does not match insert_count.")
        assert_equal(10, Bodysize.count(), "Incorrect database count.")
    end

    def test_verify_values()
        csv = BodySize::Import::CSV.new(@good_csv_data, :user => @user,
            :header_source_path => "#{RAILS_ROOT}/test/data/bodysize_header.csv")
        csv.execute()

        # Note that biovolume and log10_biovolume are not tested.  This is 
        # because the height, width, and length data in this csv file are made
        # up while the biovolume and log10_biovolume are calculated values
        # and are not read in directly from the imported data.

        bodysize = Bodysize.find_by_class_classification('Demospongiae')

        assert_equal("Largest", bodysize.notes)
        assert_equal("C. McClain", bodysize.compiler)
        assert_nil(bodysize.expert_contacted)
        assert_nil(bodysize.epoch) 
        assert_equal(Feeding.find_by_name("Hm"), bodysize.feeding)
        assert_equal("Xestospongia", bodysize.genus)
        #assert_equal(7509261330, bodysize.biovolume)
        assert_nil(bodysize.how_estimation_was_achieved)
        assert_equal(0.12345, bodysize.height)
        assert_equal("Grzimek, B. 1974. Grzimek's Animal Life Encylopedia. Van Nostrand Reinhold Co., New York.",
                     bodysize.literature_citation)
        assert_equal(Kingdom.find_by_name("Animalia"), bodysize.kingdom)
        assert_equal(Period.find_by_name("Modern"), bodysize.period)
        assert_equal(Formula.find_by_name("Rectangular Prism"), bodysize.formula)
        assert_nil(bodysize.mass)
        assert_equal("muta", bodysize.species)
        assert_equal("Demospongiae", bodysize.class_classification)
        assert_equal(Motility.find_by_name("S"), bodysize.motility)
        assert_nil(bodysize.order_classification)
        assert_equal(Phylum.find_by_name("Chordata"),  bodysize.phylum)
        assert_equal(Environment.find_by_name("Marine"), bodysize.environment)
        assert_nil(bodysize.family)
        #assert_equal(9.87559721848451, bodysize.log10_biovolume)
        assert_equal(2.43, bodysize.width)
        assert_equal(0.12345, bodysize.length)
        assert_nil(bodysize.first_description_literature_source)
        assert_nil(bodysize.confidence_comment)
        assert_nil(bodysize.other_data_source)
    end
end


class ExportTest < ActiveSupport::TestCase
    require 'fastercsv'
    fixtures :properties, :formulas

    def setup
        @ar_collection = Bodysize.find(:all)
        @user = User.find(:first)
        @export = BodySize::Export::CSV.new(@ar_collection)
    end

    def test_execute()
        require 'fastercsv'
        @export.execute()
        row_length = @export.header.length()

        # Parse the csv_string.
        # Each row should have exactly as many elements as the header.
        FasterCSV.parse(@export.csv_string, :headers => true) do |row|
            assert_equal(row_length, row.length)
        end
    end

    def test_header()
        # The header must be a non-empty array once the execute() method has
        # been called.
        assert_equal(true, @export.header.empty?())
        @export.execute()
        assert_equal(false, @export.header.empty?())
    end

    def test_fields_to_include_option()
        fields = ['kingdom', 'class_classification', :notes]
        export = BodySize::Export::CSV.new(@ar_collection, :fields_to_include => fields)
        export.execute()
        row_length = export.header.length()

        # Parse the csv_string.
        # Each row should have exactly as many elements as the header.
        FasterCSV.parse(export.csv_string, :headers => true) do |row|
            assert_equal(row_length, row.length)
            assert_equal(fields.length, row.length)
        end
    end

    def test_non_existant_fields_to_include_option()
        fields = ['bogus_attr', 'class_classification']
        export = BodySize::Export::CSV.new(@ar_collection, :fields_to_include => fields)
        assert_raises(BodySize::ExportError) {export.execute()}
    end
end
