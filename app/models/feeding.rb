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


#
# Purpose: Bodysize records have a "Feeding" which is represented by this class.
#
class Feeding < Property
  
  #
  # A feeding may be associated with many bodysize records
  #
  has_many :bodysizes
  
end
