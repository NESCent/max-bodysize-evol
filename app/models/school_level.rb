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


# = School Level
#
# Purpose: Maintain a list of school levels as valid options for user profiles
#
class SchoolLevel < Property
  
  #
  # A SchoolLevel may be associated with many users
  #
  has_many :users
  
end
