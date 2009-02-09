# == Schema Information
# Schema version: 15
#
# Table name: comments
#
#  id          :integer         not null, primary key
#  type        :string(255)
#  owner_id    :integer
#  bodysize_id :integer
#  comment     :text
#  created_at  :datetime
#  updated_at  :datetime
#


# = Private Note
#
# Purpose: Represents a Private Note. The functianality for this class comes from it's parent class
#
# Private Notes are accessible only to the bodysize creator, Approvers, and Admins
#
class PrivateNote < Comment
end
