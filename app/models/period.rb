# == Schema Information
# Schema version: 12
#
# Table name: periods
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  midpoint   :float
#  created_at :datetime
#  updated_at :datetime
#


# = Period
#
# Purpose: This class represents a time Period represented by a name and midpoint.
#
class Period < ActiveRecord::Base
  
  #
  # Each period may be associated with many Bodysize objects
  #
  has_many :bodysizes
  
  
  #
  # Purpose: Convert a period to a string by using it's name
  #
  # Input: None (Uses name)
  # Output: String - the text version of the Period
  #
  def to_s
    return "#{name}"
  end
  
  
  #
  # Purpose: Retrieve periods in a format that can be used to create a select drop down
  #
  # Input: 
  # * name (Symbol) [optional] - The field to use as the text part of the option
  # * value (Symbol) [optional] - The field to us as the value part of the option
  # 
  # Output: 
  # An Array of Arrays - Each Array has two values, where the first represents the text part of the option, and the second
  # represents the value part of the option
  #
  def self.options(name = :name, value = :id)
    return Period.find(:all, :order => 'id').map { |item| [item.name, item.id] }
  end
  
  
  #
  # Purpose: Retrieve periods in a format that can be used to create a select drop down
  # This method uses the midpoint as the value
  #
  # Input: None (Uses name, midpoint)
  #
  # Output:
  # An Array of Arrays - Each Array has two values, where the first represents the text part of the option, and the second
  # represents the value part of the option
  #
  def self.options_by_midpoint
    return Period.find(:all, :order => 'midpoint').map { |item| [item.name, item.midpoint] }
  end
  
  
end
