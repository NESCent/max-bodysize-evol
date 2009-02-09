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


# = Motility
#
# Purpose: Bodysize records have a "Motility" which is represented by this class.
#
class Motility < Property
  
  #
  # A motility may be associated with many bodysize records
  #
  has_many :bodysizes
  
end
