require File.dirname(__FILE__) + '/../test_helper'

class PropertyTest < ActiveSupport::TestCase
  fixtures :properties

# This tests the options method to make sure it returns the correct
  # datastructure with the correct number of elements.
  # This does not check the validity of the contents.
  def test_property_options
    options = Property.options
    
    assert_equal 28, options.length, "There are 28 property options"
    
    for option in options
      assert_equal 2, option.length, "Option is an array with two values"  
    end
    
  end
  
  
  def test_to_s
    property = Property.find(:first)
    assert_equal property.name, property.to_s, "Converting a property to a string gives the name of the property."
  end

end
