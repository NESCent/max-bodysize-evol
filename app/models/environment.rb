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


# = Environemtn
#
# Purpose: This class represents a the environment in which a bodysize specimen was found.
#
class Environment < Property
  
  #
  # An environment may be associated with many bodysize records
  #
  has_many :bodysizes
  
end
