# = Bodysize Helper
#
# Purpose: Create helper methods which will be available to all templates in the bodysize section.
#
module BodysizeHelper

  
  #
  # Purpose: Convert bodysize measurements to a string, or use a place-holder to indicate that the value is missing
  #
  # Input: 
  # * measurement (float) - The measurement value for a field
  # * units (string) [optional] - The unit of measurement for the given measurement
  #
  # Output:
  # * Returns the measurement if given
  # * Returns the value of indicate_when_missing, otherwise
  #
  # Note: Units is not currently used.
  #
  def measurement_to_s(measurement, units = "")
    measurement.blank? ? indicate_when_missing : "#{measurement}"
  end
  
  
  #
  # Purpose: Provide a method to indicate a value is missing, only when that value is missing
  # 
  # Input: 
  # * value (varies) [optional] - The value to indicate if missing
  #
  # Output:
  # * The value, if it exists (and is not false)
  # * An html mdash, otherwise
  #
  def indicate_when_missing(value = nil) 
    value.blank? ? "&mdash;" : value
  end


end
