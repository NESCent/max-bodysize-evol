# == Schema Information
# Schema version: 12
#
# Table name: properties
#
#  id         :integer         not null, primary key
#  type       :string(255)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#



# = Property
#
# Purpose: The Bodysize application contains a number of different types of properties which
# do not require any attributes. Each of these things is maintained by keeping a
# record of the property's name and type. This class allows these properties to be
# accessed, and modified by other data models in the application.
#
class Property < ActiveRecord::Base
  
  #
  # Purpose: Convert a property to a string by using it's name
  #
  # Input: None (Uses name)
  # Output: String - The property as text
  #
  def to_s
    return "#{self.name}"
  end
  
  
  
  #
  # Purpose: Retrieve properties in a format that can be used to create a select drop down
  # Calling Property.options will result in a list of options for all properties of 
  # all types. Calling SubclassOfPropery.options will result in a list of options only 
  # for the given Subclass.
  #
  # Input: None (Uses name, id)
  # Output: 
  # An Array of Arrays - Each Array has two values, where the first represents the text part of the option, and the second
  # represents the value part of the option
  #
  def self.options
    return self.find(:all).collect { |item| [item.name, item.id] }
  end
  
end
