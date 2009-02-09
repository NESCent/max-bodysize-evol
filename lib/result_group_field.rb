# == ResultGroupField
#
# Purpose: Maintain basic information about fields in a structured way, that can be used to 
# group search results.
#
class ResultGroupField
  
  # Allow read/write access to the main attributes
  attr_accessor :field_name, :display_name, :attribute_name
  
  
  #
  # Purpose: Create a new ResultGroupField
  # Input: 
  # * field_name (string) [optional] - The name of the database field which results can be grouped on
  # * options (hash) [optional] - Additional options:
  # ** display_name (string) - The name of the field as it should be displayed to the user
  # ** attribute_name (string) - The name of the attribute which cooresponds to this field.
  # The attribute name should be used to get the correct value from the model, instead of the field name.
  # This allows conversions to be done if necessary
  #
  # Output:
  # * A new ResultGroupField object
  #
  def initialize(field_name = nil, options = Hash.new)
    @field_name = field_name
    @display_name = options[:display_name] || @field_name.capitalize
    @attribute_name = options[:attribute_name] || @display_name.downcase
  end
  
  
  #
  # Purpose: Convert a ResultGroupField object to a string representation
  # Input: None
  # Output: A string representation of the ResultGroupField object
  #
  def to_s
    @display_name
  end
  
end
