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


# = Kingdom
#
# Purpose: This class represents a the kingdom of which a bodysize specimen is a member.
#
class Kingdom < Property
  
  #
  # A kingdom may be associated with many bodysize records
  #
  has_many :bodysizes
  
end
