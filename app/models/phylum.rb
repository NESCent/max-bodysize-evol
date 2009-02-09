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


# = Phylum
#
# Purpose: This class represents a the phylum of which a bodysize specimen is a member.
#
class Phylum < Property
  
  #
  # A phylum may be associated with many bodysize records
  #
  has_many :bodysizes
  
end
