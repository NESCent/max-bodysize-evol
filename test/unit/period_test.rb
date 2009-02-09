require File.dirname(__FILE__) + '/../test_helper'

class PeriodTest < ActiveSupport::TestCase
  fixtures :periods
  
  # This tests the options method to make sure it returns the correct
  # datastructure with the correct number of elements.
  # This does not check the validity of the contents.
  def test_period_options
    options = Period.options
    
    assert_equal 13, options.length, "There are 13 period options"
    
    for option in options
      assert_equal 2, option.length, "Option is an array with two values"  
    end
    
  end
  
  
  def test_to_s
    period = Period.find(:first)
    assert_equal period.name, period.to_s, "Converting a period to a string gives the name of the period."
  end


end
